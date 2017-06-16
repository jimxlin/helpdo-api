require 'rails_helper'

RSpec.describe PrivateTodo, type: :model do
  it { should belong_to(:creator) }

  it { should have_many(:tasks).dependent(:destroy) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:user_id) }
end
