class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :todo

  validates :is_admin, inclusion: { in: [true, false] }
end
