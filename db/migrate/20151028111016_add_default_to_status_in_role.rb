class AddDefaultToStatusInRole < ActiveRecord::Migration
  def change
  	change_column_default :roles, :status, true
  end
end
