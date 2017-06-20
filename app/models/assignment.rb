class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user, uniqueness: { scope: :task,
            message: 'User cannot be assigned to a Task multiple times' }
end
