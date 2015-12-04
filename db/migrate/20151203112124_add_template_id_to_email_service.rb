class AddTemplateIdToEmailService < ActiveRecord::Migration
  def change
    add_column :email_services, :template_id, :integer
  end
end
