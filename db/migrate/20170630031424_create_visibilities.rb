class CreateVisibilities < ActiveRecord::Migration[5.1]
  def change
    create_table :visibilities do |t|
      t.belongs_to :user
      t.belongs_to :task
      
      t.timestamps
    end
  end
end
