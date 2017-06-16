require 'rails_helper'

RSpec.describe 'Todos API', type: :request do
  let!(:user) { create(:user) }
  let!(:intruder) { create(:user) }
  let!(:todos) { create_list(:todo, 10, user_id: user.id, type: 'PrivateTodo') }
  let(:todo_id) { todos.first.id }

  # generate JWT with Knock gem
  def authenticated_header(user)
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /private_todos' do
    before do
      get(
        '/private_todos',
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

  describe 'GET /private_todos/:id' do
    before do
      get(
        "/private_todos/#{todo_id}",
        headers: authenticated_header(user)
      )
    end

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(todo_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:todo_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find PrivateTodo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      get(
        "/private_todos/#{todo_id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST /private_todos' do
    let(:valid_attributes) do
      { title: 'Shopping List', type: 'PrivateTodo' }
    end

    context 'when the request is valid' do
      before do
        post(
          '/private_todos',
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
          '/private_todos',
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

  describe 'PUT /private_todos/:id' do
    let(:valid_attributes) { { title: 'Grocery list' } }

    before do
      put(
        "/private_todos/#{todo_id}",
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
        expect(response.body).to match(/Couldn't find PrivateTodo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      put(
        "/private_todos/#{todo_id}",
        params: valid_attributes,
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /private_todos/:id' do
    it 'returns status code 204' do
      delete(
        "/private_todos/#{todo_id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/private_todos/#{todo_id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end
end
