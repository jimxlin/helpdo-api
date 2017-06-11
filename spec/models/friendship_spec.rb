require 'rails_helper'

RSpec.describe Friendship, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:friend) }

  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  describe 'friendships_and_their_inverses_must_be_unique' do
    it 'should validate uniqueness of friendships' do
      user1.friendships.create!(friend_id: user2.id)
      expect(
        user1.friendships.create(friend_id: user2.id)
      ).to_not be_valid
    end

    it 'should validate uniqueness of inverse friendships' do
      user2.friendships.create!(friend_id: user1.id)
      expect(
        user1.friendships.create(friend_id: user2.id)
      ).to_not be_valid
    end
  end
end
