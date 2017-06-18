class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :public_todo

  validates :user, uniqueness: { scope: :public_todo,
            message: 'Users cannot join a Todo multiple times' }
  validates :is_admin, inclusion: { in: [true, false] }
end
