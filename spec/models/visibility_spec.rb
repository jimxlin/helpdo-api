require 'rails_helper'

RSpec.describe Visibility, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:task) }

  let!(:user) { create(:user) }
  let!(:todo) { create(:private_todo, user_id: user.id)}
  let!(:task) { create(:task, todo_id: todo.id) }
  let!(:helper) do
    helper = create(:user)
    helper.friendships.create!(friend_id: user.id, is_accepted: true)
    helper
  end

  it 'validates user uniqueness by task' do
    task.visibilities.create(user_id: helper.id)
    visibility = task.visibilities.create(user_id: helper.id)
    expect(visibility.errors[:user].first).to eq(
      'User cannot be shown a Task multiple times'
    )
  end
end
