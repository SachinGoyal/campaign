class RemoveColumnFromContact < ActiveRecord::Migration
  def change
  	remove_column :profiles, :created_by, :integer
  	remove_column :profiles, :updated_by, :integer
  end
end
