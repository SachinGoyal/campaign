class ContactsProfiles < ActiveRecord::Migration
  def change
  	create_table :contacts_profiles, id: false do |t|
      t.references :contact, index: true, foreign_key: true, null: false
      t.references :profile, index: true, foreign_key: true, null: false
    end
  end
end
