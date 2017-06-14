class Todo < ApplicationRecord
  belongs_to :creator, class_name: :User, foreign_key: 'user_id'
  has_many :tasks, dependent: :destroy

  has_many :memberships

  has_many :members,
           ->{ where(memberships: { is_admin: false}) },
           through: :memberships,
           source: :user

  has_many :admins,
           ->{ where(memberships: { is_admin: true}) },
           through: :memberships,
           source: :user

  validates :title, presence: true
  validates :user_id, presence: true
  validates :is_shared, inclusion: { in: [true, false] }

  after_save :add_membership_if_shared

  private

  def add_membership_if_shared
    if is_shared
      memberships.create(user_id: creator.id, is_admin: true)
    end
  end
end
