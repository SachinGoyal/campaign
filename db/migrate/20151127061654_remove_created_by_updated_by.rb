class RemoveCreatedByUpdatedBy < ActiveRecord::Migration
  def change
  	remove_column :contacts, :first_name
  	remove_column :contacts, :last_name
  	remove_column :contacts, :city
  	remove_column :contacts, :country
  	remove_column :contacts, :gender
  	remove_column :contacts, :created_by, :integer
  	remove_column :contacts, :updated_by, :integer

  end
end
