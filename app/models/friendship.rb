class Friendship < ApplicationRecord
  # TODO add ability to block users
  belongs_to :user
  belongs_to :friend, class_name: "User"

  validate :friendships_and_their_inverses_must_be_unique

  def friendships_and_their_inverses_must_be_unique
    if Friendship.where({ user_id: user_id, friend_id: friend_id }).exists?
      errors.add(:friend_id, "is already friends or already sent friend request")
    end

    if Friendship.where({ user_id: friend_id, friend_id: user_id }).exists?
      errors.add(:friend_id, "is already friends or already received friend request" )
    end
  end
end
