class AddStatsToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :opens_total, :integer
    add_column :email_services, :unique_opens, :integer
    add_column :email_services, :clicks_total, :integer
    add_column :email_services, :unique_clicks, :integer
    add_column :email_services, :unique_subscriber_clicks, :integer
    add_column :email_services, :hard_bounces, :integer
    add_column :email_services, :soft_bounces, :integer
    add_column :email_services, :unsubscribed, :integer
    add_column :email_services, :forwards_count, :integer
    add_column :email_services, :forwards_opens, :integer
    add_column :email_services, :emails_sent, :integer
    add_column :email_services, :abuse_reports, :integer    
  end
end