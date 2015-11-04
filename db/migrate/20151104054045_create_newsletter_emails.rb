class CreateNewsletterEmails < ActiveRecord::Migration
  def change
    create_table :newsletter_emails do |t|
      t.references :newsletter
      t.references :profile
      t.string :emails

      t.timestamps null: false
    end
  end
end
