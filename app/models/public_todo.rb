class PublicTodo < Todo
  has_many :memberships, dependent: :destroy

  has_many :members,
           ->{ where(memberships: { is_admin: false}) },
           through: :memberships,
           source: :user

  has_many :admins,
           ->{ where(memberships: { is_admin: true}) },
           through: :memberships,
           source: :user

  after_save :create_membership

  private

  def create_membership
    memberships.create(user_id: creator.id, is_admin: true)
  end
end
