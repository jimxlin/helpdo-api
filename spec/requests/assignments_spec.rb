require 'rails_helper'

RSpec.describe 'Assignments API', type: :request do
  let!(:user) { create(:user) }
  let!(:todo) { create(:public_todo, user_id: user.id) }
  let!(:task) { create(:task, todo_id: todo.id) }
  let!(:assignees) do
    assignees = create_list(:user, 5)
    assignees.each do |assignee|
      assignee.memberships.create(public_todo_id: todo.id, is_admin: false)
      assignee.assignments.create(task_id: task.id)
    end
    assignees
  end
  let!(:unassigned) do
    unassigned = create(:user)
    unassigned.memberships.create(public_todo_id: todo.id, is_admin: false)
    unassigned
  end
  let(:todo_id) { todo.id }
  let(:task_id) { task.id }
  let(:id) { assignees.first.assignments.first.id }
  let!(:intruder) { create(:user) }

  describe 'GET /public_todos/:public_todo_id/tasks/:task_id/assignments' do
    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    before do
      get(
        "/public_todos/#{todo_id}/tasks/#{task_id}/assignments",
        headers: authenticated_header(user)
      )
    end

    context 'when task exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all todo task assignees' do
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

  describe 'POST /public_todos/:public_todo_id/tasks/:task_id/assignments' do
    context 'when the request is valid' do
      before do
        post(
          "/public_todos/#{todo_id}/tasks/#{task_id}/assignments",
          params: { user_id: unassigned.id },
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates the assignment' do
        expect(Assignment.find_by(user_id: unassigned.id)).to be_truthy
      end
    end

    context 'when the request is invalid' do
      before do
        post(
          "/public_todos/#{todo_id}/tasks/#{task_id}/assignments",
          params: {},
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns an assignee-member failure message' do
        expect(response.body).to match(/Assignee is not a member of this Todo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      post(
        "/public_todos/#{todo_id}/tasks/#{task_id}/assignments",
        params: { user_id: unassigned.id },
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end

    it 'returns status code 403 for non-member assignment creation' do
      post(
        "/public_todos/#{todo_id}/tasks/#{task_id}/assignments",
        params: { user_id: intruder.id },
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(403)
      expect(response.body).to match(/Assignee is not a member of this Todo/)
    end

  end

  describe 'DELETE /public_todos/:public_todo_id/tasks/:task_id/assignments/:id' do
    it 'returns status code 204' do
      delete(
        "/public_todos/#{todo_id}/tasks/#{task_id}/assignments/#{id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/public_todos/#{todo_id}/tasks/#{task_id}/assignments/#{id}",
        headers: authenticated_header(assignees.second)
      )
      expect(response).to have_http_status(401)
    end
  end
end
