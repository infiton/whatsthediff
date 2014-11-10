class RemoveDataColumnsFromProjects < ActiveRecord::Migration
  def change
  	remove_column :projects, :data_id
  	remove_column :projects, :target_data_id
  end
end
