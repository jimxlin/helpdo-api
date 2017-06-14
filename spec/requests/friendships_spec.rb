require 'rails_helper'

RSpec.describe 'Friendships API', type: :request do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }

  # generate JWT with Knock gem
  def authenticated_header(user)
    token = Knock::AuthToken.new(payload: { sub: user.id }).token
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /friendships' do
    before do
      # friends
      user.friendships.create(friend_id: create(:user).id, is_accepted: true)
      user.friendships.create(friend_id: create(:user).id, is_accepted: true)

      # sent friend requests
      user.friendships.create(friend_id: create(:user).id)
      user.friendships.create(friend_id: create(:user).id)

      # received friend requests
      create(:user).friendships.create(friend_id: user.id)
      create(:user).friendships.create(friend_id: user.id)

      get(
        '/friendships',
        headers: authenticated_header(user)
      )
    end

    it 'returns all friends and friend requests' do
      # Note `json` is a custom spec helper to parse JSON responses
      expect(json['friends'].length).to eq(2)
      expect(json['sent_friend_requests'].length).to eq(2)
      expect(json['received_friend_requests'].length).to eq(2)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /friendships' do
    let(:valid_attributes) do
      { friend_id: other_user.id }
    end

    context 'when the friendship does not exist' do
      before do
        post(
          '/friendships',
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'creates a friendship request' do
        friendship = user.friendships.first
        expect(friendship.user_id).to eq(user.id)
        expect(friendship.friend_id).to eq(other_user.id)
        expect(friendship.is_accepted).to be false
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the friendship already exists' do
      before do
        user.friendships.create(friend_id: other_user.id)
        post(
          '/friendships',
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Friend is already friends or already sent friend request/)
      end
    end
  end

  describe 'PUT /friendships/:id' do
    let(:valid_attributes) do
      { is_accepted: true }
    end

    context 'when accepting a friend request from another user' do
      before do
        friendship = other_user.friendships.create(friend_id: user.id);
        put(
          "/friendships/#{friendship.id}",
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'updates the friendship to accepted status' do
        expect(user.inverse_friendships.first.is_accepted).to be true
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end

    context 'when accepting a friend request created by self' do
      before do
        friendship = user.friendships.create(friend_id: user.id);
        put(
          "/friendships/#{friendship.id}",
          params: valid_attributes,
          headers: authenticated_header(user)
        )
      end

      it 'does not update the friendship to accepted status' do
        expect(user.friendships.first.is_accepted).to be false
        expect(response.body).to match(/Cannot accept own friend request/)
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end

  describe 'DELETE /friendships/:id' do
    before do
      friendship = user.friendships.create(friend_id: user.id);
      delete(
        "/friendships/#{friendship.id}",
        headers: authenticated_header(user)
      )
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end
