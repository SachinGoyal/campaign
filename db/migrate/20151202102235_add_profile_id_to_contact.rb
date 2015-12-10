class AddProfileIdToContact < ActiveRecord::Migration
  def change
  	add_column :contacts, :profile_id , :integer
  end
end
