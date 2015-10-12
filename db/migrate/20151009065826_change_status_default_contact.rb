class ChangeStatusDefaultContact < ActiveRecord::Migration
  def change
  	change_column_default :contacts, :status, true
  end
end
