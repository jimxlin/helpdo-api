class User < ApplicationRecord
  # rows where user_id == self.id
  has_many :friendships, dependent: :destroy

  # rows where friend_id == self.id
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id",
            dependent: :destroy

  has_many :friends,          # request was sent by self
            ->{ where(friendships: { is_accepted: true}) },
            through: :friendships,
            source: :friend

  has_many :inverse_friends,  # request was sent by the friend
            ->{ where(friendships: { is_accepted: true}) },
            through: :inverse_friendships,
            source: :user

  has_many :friend_requests, # sent friend requests
            ->{ where(friendships: { is_accepted: false}) },
            through: :friendships,
            source: :friend

  has_many :inverse_friend_requests, # received friend requests
            -> { where(friendships: { is_accepted: false}) },
            through: :inverse_friendships,
            source: :user

  has_many :todos, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true

  has_secure_password

  def all_friends
    friends + inverse_friends
  end

  # def pending_friend_requests
  #   friend_requests + inverse_friend_requests
  # end
end
