class AddIsAcceptedToFriendships < ActiveRecord::Migration[5.1]
  def change
    add_column :friendships, :is_accepted, :boolean, default: false
  end
end
