class AddListIdAndCampaignIdToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :list_id, :string
    add_column :email_services, :campaign_id, :string
  end
end
