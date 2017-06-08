class CreateTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tasks do |t|
      t.belongs_to :todo
      t.string :name
      t.boolean :is_done
      t.integer :helpers , array: true, default: []

      t.timestamps
    end
    add_index :tasks, :name
  end
end
