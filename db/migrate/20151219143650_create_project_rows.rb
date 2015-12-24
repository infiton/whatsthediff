class CreateProjectRows < ActiveRecord::Migration
  CREATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP'
  UPDATE_TIMESTAMP = 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'

  def change
    create_table :project_rows do |t|
      t.integer :project_id
      t.string :data_type
      t.string :uid
      t.string :digest

      #override timestamps to allow for bulk inserts :)
      #from: http://www.mikeperham.com/2014/05/17/setting-mysql-datetime-column-defaults-in-rails/
      t.column :created_at, CREATE_TIMESTAMP
      t.column :updated_at, UPDATE_TIMESTAMP
    end

    add_foreign_key :project_rows, :projects
    add_index :project_rows, :data_type
    add_index :project_rows, :digest
  end
end
