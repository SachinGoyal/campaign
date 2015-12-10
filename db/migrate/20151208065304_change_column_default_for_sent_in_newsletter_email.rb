class ChangeColumnDefaultForSentInNewsletterEmail < ActiveRecord::Migration
  def change
  	change_column_default :newsletter_emails, :sent, false
  end
end
