class AddScheduledAtToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :scheduled_at, :datetime
  end
end
