require 'rails_helper'

RSpec.describe Assignment, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:task) }

  let!(:user) { create(:user) }
  let!(:todo) { create(:public_todo, user_id: user.id)}
  let!(:task) { create(:task, todo_id: todo.id) }
  let!(:member) do
    member = create(:user)
    member.memberships.create(public_todo_id: member.id)
    member
  end

  it 'validates user uniqueness by task' do
    task.assignments.create(user_id: member.id)
    assignment = task.assignments.create(user_id: member.id)
    expect(assignment.errors[:user].first).to eq(
      'User cannot be assigned to a Task multiple times'
    )
  end
end
