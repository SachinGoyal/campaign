class RemoveUserIdFromCampaign < ActiveRecord::Migration
  def change
    #remove_column :campaigns, :user_id, :integer
    remove_column :templates, :user_id, :integer
    #remove_column :users, :user_type, :integer
  end
end
