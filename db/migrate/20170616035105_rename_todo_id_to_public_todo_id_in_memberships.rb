class RenameTodoIdToPublicTodoIdInMemberships < ActiveRecord::Migration[5.1]
  def change
    rename_column :memberships, :todo_id, :public_todo_id
  end
end
