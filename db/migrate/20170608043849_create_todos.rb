class CreateTodos < ActiveRecord::Migration[5.1]
  def change
    create_table :todos do |t|
      t.belongs_to :user, index: true
      t.string :title
      t.boolean :is_shared

      t.timestamps
    end
    add_index :todos, :title
  end
end
