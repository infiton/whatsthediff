class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :state
      t.integer :user_id
      t.integer :target_user_id
      t.string :field_signature

      t.timestamps null: false
    end

    add_foreign_key :projects, :users
    add_index :projects, :target_user_id
  end
end
