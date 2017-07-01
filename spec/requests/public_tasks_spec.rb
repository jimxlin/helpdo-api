require 'rails_helper'

RSpec.describe 'Tasks API' do
  let!(:user) { create(:user) }
  let!(:intruder) { create(:user) }
  let!(:todo) { create(:public_todo, user_id: user.id) }
  let!(:tasks) { create_list(:task, 20, todo_id: todo.id) }
  let(:todo_id) { todo.id }
  let(:id) { tasks.first.id }

  describe 'GET /public_todos/:todo_id/tasks' do
    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    before do
      get(
        "/public_todos/#{todo_id}/tasks",
        headers: authenticated_header(user)
      )
    end

    context 'when todo exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all todo tasks' do
        # Note `json` is a custom spec helper to parse JSON responses
        expect(json.size).to eq(20)
      end
    end

    context 'when todo does not exist' do
      let(:todo_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Todo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      get(
        "/public_todos/#{todo_id}/tasks",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'GET /public_todos/:todo_id/tasks/:id' do
    before do
      get(
        "/public_todos/#{todo_id}/tasks/#{id}",
        headers: authenticated_header(user)
      )
    end

    context 'when todo task exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the task' do
        expect(json['id']).to eq(id)
      end
    end

    context 'when the todo task does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Task/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      get(
        "/public_todos/#{todo_id}/tasks/#{id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST /public_todos/:todo_id/tasks' do
    let(:valid_attributes) { { name: 'Get milk', is_done: false } }

    context 'when the request is valid' do
      before do
        post(
          "/public_todos/#{todo_id}/tasks",
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'returns the todo that the task belongs to' do
        expect(json['title']).to eq(todo.title)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before do
        post(
          "/public_todos/#{todo_id}/tasks",
          params: {},
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Validation failed: Name can't be blank/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      post(
        "/public_todos/#{todo_id}/tasks",
        params: valid_attributes,
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'PUT /public_todos/:todo_id/tasks/:id' do
    let(:valid_attributes) { { is_done: true } }

    before do
      put(
        "/public_todos/#{todo_id}/tasks/#{id}",
        params: valid_attributes,
        headers: authenticated_header(user)
      )
    end

    context 'when the task exists' do
      it 'updates the task' do
        updated_task = Task.find(id)
        expect(updated_task.is_done).to be true
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the task does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Task/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      put(
        "/public_todos/#{todo_id}/tasks/#{id}",
        params: valid_attributes,
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /public_todos/:id' do
    it 'returns status code 204' do
      delete(
        "/public_todos/#{todo_id}/tasks/#{id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/public_todos/#{todo_id}/tasks/#{id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end
end
