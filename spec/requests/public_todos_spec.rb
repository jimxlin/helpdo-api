require 'rails_helper'

RSpec.describe 'PublicTodos API', type: :request do
  let!(:user) { create(:user) }
  let!(:intruder) { create(:user) }
  let!(:todos) { create_list(:todo, 10, user_id: user.id, type: 'PublicTodo') }
  let(:todo_id) { todos.first.id }

end
