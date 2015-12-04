class AddUserIdToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :user_id, :integer
  end
end
