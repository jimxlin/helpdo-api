class User < ApplicationRecord
  # rows where user_id == self.id
  has_many :friendships, dependent: :destroy

  # rows where friend_id == self.id
  has_many :received_friendships, class_name: "Friendship", foreign_key: "friend_id",
            dependent: :destroy

  has_many :sought_friends,
            ->{ where(friendships: { is_accepted: true}) },
            through: :friendships,
            source: :friend # friend_id

  has_many :received_friends,
            ->{ where(friendships: { is_accepted: true}) },
            through: :received_friendships,
            source: :user # user_id

  has_many :seeking_friendship, # sent friend requests
            ->{ where(friendships: { is_accepted: false}) },
            through: :friendships,
            source: :friend

  has_many :receiving_friendships, # received friend requests
            -> { where(friendships: { is_accepted: false}) },
            through: :received_friendships,
            source: :user

  has_many :todos, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true

  has_secure_password
end
