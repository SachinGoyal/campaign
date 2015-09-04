class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :free_emails
      t.boolean :status
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
