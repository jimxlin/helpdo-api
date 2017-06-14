require 'rails_helper'

RSpec.describe Todo, type: :model do
  it { should belong_to(:creator) }

  it { should have_many(:memberships) }
  it { should have_many(:members) }
  it { should have_many(:admins) }

  it { should have_many(:tasks).dependent(:destroy) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:user_id) }
end
