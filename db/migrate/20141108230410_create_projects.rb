class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|

      t.integer :base_user_id
      t.integer :target_user_id
      t.integer :base_data_id
      t.integer :target_data_id
      t.string :state

      t.timestamps
    end
  end
end
