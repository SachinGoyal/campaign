class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :site_title
      t.string :free_emails
      t.string :admin_email
      t.string :admin_footer_content
      t.timestamps null: false
    end
  end
end
