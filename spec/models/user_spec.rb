require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:private_todos).dependent(:destroy) }
  it { should have_many(:public_todos) }

  it { should have_many(:memberships).dependent(:destroy) }
  it { should have_many(:assignments).dependent(:destroy) }
  it { should have_many(:assigned_tasks) }

  it { should have_many(:friendships).dependent(:destroy) }
  it { should have_many(:inverse_friendships).dependent(:destroy) }
  it { should have_many(:friends) }
  it { should have_many(:inverse_friends) }
  it { should have_many(:friend_requests) }
  it { should have_many(:inverse_friend_requests) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password_digest) }
end
