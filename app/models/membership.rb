class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :todo

  validates :user, uniqueness: { scope: :todo,
            message: 'Users cannot join a Todo multiple times' }
  validates :is_admin, inclusion: { in: [true, false] }
end
