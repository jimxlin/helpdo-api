class CreateMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :members do |t|
      t.belongs_to :todo
      t.belongs_to :user
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
