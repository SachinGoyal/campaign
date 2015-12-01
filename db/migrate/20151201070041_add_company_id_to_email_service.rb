class AddCompanyIdToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :company_id, :integer
  end
end
