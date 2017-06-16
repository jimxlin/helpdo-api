class DeleteIsSharedFromTodos < ActiveRecord::Migration[5.1]
  def change
    remove_column :todos, :is_shared
  end
end
