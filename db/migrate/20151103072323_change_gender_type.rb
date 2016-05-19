class ChangeGenderType < ActiveRecord::Migration
  def change
  	change_column :contacts, :gender, :boolean, default: true
  end
end
