class AddTypeToTodos < ActiveRecord::Migration[5.1]
  def change
    add_column :todos, :type, :string
  end
end
