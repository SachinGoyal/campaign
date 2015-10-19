class ChangeEditableDefaultInRole < ActiveRecord::Migration
  def change
  	change_column_default :roles, :editable, true
  end
end
