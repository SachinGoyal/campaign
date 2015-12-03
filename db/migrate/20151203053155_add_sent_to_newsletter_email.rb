class AddSentToNewsletterEmail < ActiveRecord::Migration
  def change
    add_column :newsletter_emails, :sent, :boolean, default: true
  end
end
