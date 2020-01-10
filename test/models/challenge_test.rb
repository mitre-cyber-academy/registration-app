require 'test_helper'

class ChallengeTest < ActiveSupport::TestCase
  def setup
    create(:active_game)
  end

  test 'challenge state open' do
    create(:unstarted_game)

    assert_equal true, create(:challenge, state: :open).challenge_open?
    assert_equal false, create(:challenge, state: :closed).challenge_open?
    assert_equal false, create(:challenge, state: :force_closed).challenge_open?
  end

  test 'challenge open when game is open' do
    assert_equal true, create(:challenge, state: :open).open?
  end

  test 'challenge solved' do
    challenge = create(:challenge, state: :open)
    create(:solved_challenge, challenge: challenge, team: create(:team))
    assert_equal false, create(:challenge, state: :open).solved?
  end

  test 'already opened challenge is not available to be opened' do
    assert_equal false, create(:challenge, state: :open).available?
  end

  test 'challenge force closed' do
    assert_equal true, create(:challenge, state: :force_closed).force_closed?
  end

  test 'set state' do
    challenge = create(:challenge, state: :open)
    challenge.state!('force_closed')
    assert_equal 'force_closed', challenge.state
  end

  test 'post state change message' do
    open_challenge = create(:challenge, state: :open)
    forced_challenge = create(:challenge, state: :force_closed)
    assert_difference 'Message.count', +2 do
      open_challenge.update_attributes(state: 'force_closed')
      forced_challenge.update_attributes(state: 'open')
    end
    message = Message.last
    assert I18n.t('challenge.state_change_message', state: 'open'.titleize), message.title
  end
end
