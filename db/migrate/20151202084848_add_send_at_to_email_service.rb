class AddSendAtToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :send_at, :datetime
  end
end
