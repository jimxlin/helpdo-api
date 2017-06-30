class Task < ApplicationRecord
  belongs_to :todo
  has_many :assignments
  has_many :assigned_members, through: :assignments, source: :user

  has_many :visibilities, dependent: :destroy
  has_many :visible_users, through: :visibilities, source: :user

  validates :name, presence: true
end
