class ContactsAttributes < ActiveRecord::Migration
  def change
  	create_table :contacts_attributes, id: false do |t|
      t.references :contact, index: true, foreign_key: true, null: false
      t.references :attribute, index: true, foreign_key: true, null: false
    end
  end
end
