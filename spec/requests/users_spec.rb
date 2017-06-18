require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let(:new_user)   { build(:user) }
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /users?query=' do
    before { create(:user, name: other_user.name) }

    # Note `authenticated_header` is a custom spec helper to generate JWT with Knock gem
    it 'finds a user based on name' do
      get(
        "/users?query=#{other_user.name}",
        headers: authenticated_header(user)
      )
      expect(json[0][1]).to eq(other_user.name)
      expect(json[1][1]).to eq(other_user.name)
    end

    it 'returns an empty array if no there are no matches' do
      get(
        "/users?query=",
        headers: authenticated_header(user)
      )
      expect(json).to be_empty
    end
  end

  describe 'POST /users' do
    before do
      post(
        '/users',
        params: attributes
      )
    end

    context 'when the request is valid' do
      let(:attributes) do
        {
          name: new_user.name,
          email: new_user.email,
          password: new_user.password,
          password_confirmation: new_user.password
        }
      end

      it 'creates a new user' do
        expect(json['email']).to eq(new_user.email)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      let(:attributes) { {} }

      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end

      it 'returns failure message' do
        expect(json['message'])
          .to match(/Validation failed: Name can't be blank, Email can't be blank, Password digest can't be blank, Password can't be blank/)
      end
    end
  end
end
