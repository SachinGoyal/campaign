class AddSampleToNewsletterEmail < ActiveRecord::Migration
  def change
    add_column :newsletter_emails, :sample, :boolean
  end
end
