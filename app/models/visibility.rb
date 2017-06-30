class Visibility < ApplicationRecord
  belongs_to :user
  belongs_to :task

  validates :user, uniqueness: { scope: :task,
            message: 'User cannot be shown a Task multiple times' }
end
