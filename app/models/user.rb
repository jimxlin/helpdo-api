class User < ApplicationRecord
  has_many :friendships, dependent: :destroy

  has_many :received_friendships, class_name: "Friendship", foreign_key: "friend_id",
            dependent: :destroy

  has_many :active_friends,
            ->{ where(friendships: { is_accepted: true}) },
            through: :friendships,
            source: :friend

  has_many :received_friends,
            ->{ where(friendships: { is_accepted: true}) },
            through: :received_friendships,
            source: :user

  has_many :pending_friends,
            ->{ where(friendships: { is_accepted: false}) },
            through: :friendships,
            source: :friend

  has_many :requested_friendships,
            -> { where(friendships: { is_accepted: false}) },
            through: :received_friendships,
            source: :user

  has_many :todos, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true
  validates :password_digest, presence: true

  has_secure_password
end
