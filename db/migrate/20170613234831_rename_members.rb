class RenameMembers < ActiveRecord::Migration[5.1]
  def change
    rename_table :members, :memberships
  end
end
