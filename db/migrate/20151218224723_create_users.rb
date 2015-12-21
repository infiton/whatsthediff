class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :company
      t.string :email

      t.timestamps null: false
    end

    add_index :users, :email
  end
end