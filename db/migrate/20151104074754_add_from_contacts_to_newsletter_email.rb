class AddFromContactsToNewsletterEmail < ActiveRecord::Migration
  def change
    add_column :newsletter_emails, :from_contacts, :boolean
  end
end
