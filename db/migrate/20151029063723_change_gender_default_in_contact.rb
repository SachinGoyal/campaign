class ChangeGenderDefaultInContact < ActiveRecord::Migration
  def change
  	  	change_column_default :contacts, :gender, true

  end
end
