class CreateProjectResults < ActiveRecord::Migration
  def change
    create_table :project_results do |t|
      t.integer :project_id
      t.string :result_type
      t.string :filename
    end

    add_foreign_key :project_results, :projects
    add_index :project_results, :result_type
  end
end
