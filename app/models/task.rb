class Task < ApplicationRecord
  belongs_to :todo
  has_many :assignments
  has_many :assigned_members, through: :assignments, source: :user

  validates :name, presence: true
end
