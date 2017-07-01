require 'rails_helper'

RSpec.describe 'Visibilities API', type: :request do
  let!(:user) { create(:user) }
  let!(:friends) do
    friends = create_list(:user, 5)
    friends.each do |friend|
      user.friendships.create(friend_id: friend.id, is_accepted: true)
    end
    friends
  end
  let!(:todo) { create(:private_todo, user_id: user.id) }
  let!(:task) { create(:task, todo_id: todo.id) }
  let(:todo_id) { todo.id }
  let(:task_id) { task.id }
  let(:id) { task.visibilities.create(user_id: friends.first.id).id }
  let!(:intruder) { create(:user) }

  describe 'Get /private_todos/:private_todo_id/tasks/:task_id/visibilities' do
    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    before do
      friends.each do |friend|
        task.visibilities.create(user_id: friend.id)
      end

      get(
        "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities",
        headers: authenticated_header(user)
      )
    end

    context 'when task exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all friends that can see the todo task' do
        # Note `json` is a custom spec helper to parse JSON responses
        expect(json.size).to eq(5)
      end
    end

    context 'when task does not exist' do
      let(:task_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Task/)
      end
    end
  end

  describe 'POST /private_todos/:private_todo_id/tasks/:task_id/visibilities' do
    context 'when the request is valid' do
      before do
        post(
          "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities",
          params: { user_id: friends.first.id },
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates the visibility' do
        expect(Visibility.find_by(user_id: friends.first.id)).to be_truthy
      end
    end

    context 'when the request is invalid' do
      before do
        post(
          "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities",
          params: { user_id: intruder.id },
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns an visibility-friend failure message' do
        expect(response.body).to match(/Can only share tasks with friends/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      post(
        "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities",
        params: { user_id: friends.first.id },
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /private_todos/:private_todo_id/tasks/:task_id/visibilities/:id' do
    it 'returns status code 204' do
      delete(
        "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities/#{id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/private_todos/#{todo_id}/tasks/#{task_id}/visibilities/#{id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end
end
