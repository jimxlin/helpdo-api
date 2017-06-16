class Todo < ApplicationRecord
  belongs_to :creator, class_name: :User, foreign_key: 'user_id'
  has_many :tasks, dependent: :destroy

  validates :title, presence: true
  validates :user_id, presence: true
  validates :type, presence: true
end
