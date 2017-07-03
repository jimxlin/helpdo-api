require 'rails_helper'

RSpec.describe 'Memberships API', type: :request do
  let!(:user) { create(:user) }
  let!(:friend) do
    friend = create(:user)
    user.friendships.create(friend_id: friend.id, is_accepted: true)
    friend
  end
  let!(:other_user) { create(:user) }
  let!(:todo) { create(:public_todo, user_id: user.id) }
  let!(:admins) { create_list(:user, 4) }
  let!(:members) { create_list(:user, 10) }
  let(:todo_id) { todo.id }
  let(:id) { Membership.find_by(user_id: members.first.id).id }

  let!(:memberships) do
    admins.each do |admin|
      admin.memberships.create!(public_todo_id: todo.id, is_admin: true)
    end
    members.each do |member|
      member.memberships.create(public_todo_id: todo.id, is_admin: false)
    end
    todo.memberships
  end

  let!(:intruder) { create(:user) }

  describe 'GET /public_todos/:todo_id/memberships' do
    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    before do
      get(
        "/public_todos/#{todo_id}/memberships",
        headers: authenticated_header(user)
      )
    end

    context 'when todo exists' do
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns all todo members' do
        # Note `json` is a custom spec helper to parse JSON responses
        expect(json['admins'].size).to eq(5)
        expect(json['members'].size).to eq(10)
      end
    end

    context 'when todo does not exist' do
      let(:todo_id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find PublicTodo/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      get(
        "/public_todos/#{todo_id}/memberships",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'POST /public_todos/:todo_id/memberships' do
    let(:valid_attributes) { { user_id: friend.id, is_admin: false } }

    context 'when the request is valid' do
      before do
        post(
          "/public_todos/#{todo_id}/memberships",
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'creates the members' do
        expect(Membership.find_by(user_id: friend.id)).to be_truthy
      end
    end

    context 'when the request is invalid' do
      before do
        post(
          "/public_todos/#{todo_id}/memberships",
          params: {user_id: other_user.id, is_admin: false},
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns a validation failure message' do
        expect(response.body).to match(/Can only add members from friends/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      post(
        "/public_todos/#{todo_id}/memberships",
        params: valid_attributes,
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'PUT /public_todos/:todo_id/memberships/:id' do
    let(:attributes) { { user_id: members.first.id, is_admin: true } }

    before do
      put(
        "/public_todos/#{todo_id}/memberships/#{id}",
        params: attributes,
        headers: authenticated_header(user)
      )
    end

    context 'when the membership exists' do
      it 'updates the membership' do
        updated_membership = Membership.find(id)
        expect(updated_membership.is_admin).to be true
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when the membership does not exist' do
      let(:id) { 0 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Membership/)
      end
    end

    context 'when the membership is for the creator' do
      let(:id) { user.memberships.first.id }

      it 'returns status code 403' do
        expect(response).to have_http_status(403)
      end

      it 'returns an unauthorized message' do
        expect(response.body).to match(/Cannot change creator membership/)
      end
    end

    it 'returns status code 401 for unauthorized users' do
      put(
        "/public_todos/#{todo_id}/memberships/#{id}",
        params: attributes,
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end
  end

  describe 'DELETE /public_todos/:public_todo_id/memberships/:id' do
    it 'returns status code 204' do
      delete(
        "/public_todos/#{todo_id}/memberships/#{id}",
        headers: authenticated_header(user)
      )
      expect(response).to have_http_status(204)
    end

    it 'returns status code 401 for unauthorized users' do
      delete(
        "/public_todos/#{todo_id}/memberships/#{id}",
        headers: authenticated_header(intruder)
      )
      expect(response).to have_http_status(401)
    end

    it 'returns status code 403 when deleting creator membership' do
      delete(
        "/public_todos/#{todo_id}/memberships/#{user.memberships.first.id}",
        headers: authenticated_header(admins.first)
      )
      expect(response).to have_http_status(403)
    end
  end
end
