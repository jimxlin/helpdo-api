require 'rails_helper'

RSpec.describe Membership, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:public_todo) }

  let!(:user) { create(:user) }
  let!(:todo) { create(:public_todo, user_id: user.id)}
  let!(:member) { create(:user) }

  it 'validates user uniqueness by todo' do
    todo.memberships.create(user_id: member.id)
    membership = todo.memberships.create(user_id: member.id)
    expect(membership.errors[:user].first).to eq(
      'Users cannot join a Todo multiple times'
    )
  end
end
