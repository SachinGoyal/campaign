class ContactsNewsletters < ActiveRecord::Migration
  def change
  	create_table :contacts_newsletters, id: false do |t|
      t.references :contact, index: true, foreign_key: true, null: false
      t.references :newsletter, index: true, foreign_key: true, null: false
    end
  end
end
