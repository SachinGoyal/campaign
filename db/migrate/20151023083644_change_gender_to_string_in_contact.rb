class ChangeGenderToStringInContact < ActiveRecord::Migration
  def change
  	remove_column :contacts, :gender_id, :integer
  	add_column :contacts, :gender, :string
  end
end
