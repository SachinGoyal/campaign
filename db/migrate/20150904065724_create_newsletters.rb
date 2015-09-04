class CreateNewsletters < ActiveRecord::Migration
  def change
    create_table :newsletters do |t|
      t.references :campeign, index: true, foreign_key: true
      t.references :template, index: true, foreign_key: true
      t.string :name
      t.string :subject
      t.string :from_name
      t.string :from_address
      t.string :reply_email
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
