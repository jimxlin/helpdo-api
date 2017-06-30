require 'rails_helper'

RSpec.describe Task, type: :model do
  it { should belong_to(:todo) }
  it { should have_many(:assignments) }
  it { should have_many(:assigned_members) }
  it { should have_many(:visibilities).dependent(:destroy) }
  it { should have_many(:visible_users) }

  it { should validate_presence_of(:name) }
end
