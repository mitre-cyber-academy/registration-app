require 'test_helper'

class GamesControllerTest < ActionController::TestCase

  def setup
    create(:active_game)
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test 'cannot get summary before game is open' do
    create(:unstarted_game)

    get :summary
    assert_redirected_to @controller.user_root_path
    assert_equal flash[:alert], I18n.t('game.before_competition')
  end

  test "should get summary during game" do
    get :summary
    assert_response :success
  end

  test "should get summary after game" do
    create(:ended_game)

    get :summary
    assert_response :success
  end

  test 'guest and user cannot access resume unless they are an admin' do
    user = create(:user_with_resume)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :resumes # Nobody is signed in
    end
    sign_in user
    assert_raises(ActiveRecord::RecordNotFound) do
      get :resumes # User is signed in
    end
  end

  test 'admin can access resume' do
    user = create(:user_with_resume)
    sign_in create(:admin)
    get :resumes
    assert_response :success
    assert_equal "application/zip", response.content_type
  end

  test 'guest and user cannot access transcript' do
    user = create(:user_with_resume)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :transcripts # Nobody is signed in
    end
    sign_in user
    assert_raises(ActiveRecord::RecordNotFound) do
      get :transcripts # User is signed in
    end
  end

  test 'guest and user cannot access show as markdown' do
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, format: :markdown # Nobody is signed in
    end
    sign_in create(:user)
    assert_raises(ActiveRecord::RecordNotFound) do
      get :show, format: :markdown # User is signed in
    end
  end

  test 'admin can access transcript' do
    user = create(:user_with_resume)
    sign_in create(:admin)
    get :transcripts
    assert_response :success
    assert_equal "application/zip", response.content_type
  end

  test 'admin can access show as markdown' do
    sign_in create(:admin)
    get :show, format: :markdown
    assert_response :success
    assert_equal "text/markdown", response.content_type
  end
end
