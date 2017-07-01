require 'rails_helper'

RSpec.describe 'PublicTodos API', type: :request do
  let!(:user) { create(:user) }
  let!(:todos) { create_list(:public_todo, 10, user_id: user.id) }
  let!(:member) do
    member = create(:user)
    member.memberships.create(public_todo_id: member.id)
    member
  end
  let!(:intruder) { create(:user) }
  let(:todo_id) { todos.first.id }

  describe 'GET /public_todos' do
    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    before do
      get(
        '/public_todos',
        headers: authenticated_header(user)
      )
    end

    it 'returns all todos' do
      # Note `json` is a custom spec helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /public_todos' do
    let(:valid_attributes) do
      { title: 'Shopping List', type: 'PublicTodo' }
    end

    context 'when the request is valid' do
      before do
        post(
          '/public_todos',
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'creates a todo' do
        expect(json['title']).to eq('Shopping List')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do
        post(
          '/public_todos',
          params: { title: '' },
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Title can't be blank/)
      end
    end
  end

  describe 'PUT /public_todos/:id' do
    let(:valid_attributes) { { title: 'Grocery list' } }

    before do
      put(
        "/public_todos/#{todo_id}",
        params: valid_attributes,
        headers: authenticated_header(user)
      )
    end

    context 'when the record exists' do
      it 'updates the record' do
        updated_todo = Todo.find(todo_id)
        expect(updated_todo.title).to match(/Grocery list/)
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the todo does not exist' do
      let(:todo_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find PublicTodo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      put(
        "/public_todos/#{todo_id}",
        params: valid_attributes,
        headers: authenticated_header(member)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /public_todos/:id' do
    it 'returns status code 204' do
      delete(
        "/public_todos/#{todo_id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/public_todos/#{todo_id}",
        headers: authenticated_header(member)
      )
      expect(response).to have_http_status(401)
    end
  end
end
