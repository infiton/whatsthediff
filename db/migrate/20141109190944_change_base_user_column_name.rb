class ChangeBaseUserColumnName < ActiveRecord::Migration
  def change
  	rename_column :projects, :base_user_id, :user_id
  	rename_column :projects, :base_data_id, :data_id
  end
end
