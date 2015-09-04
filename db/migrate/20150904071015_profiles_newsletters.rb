class ProfilesNewsletters < ActiveRecord::Migration
  def change
  	create_table :profiles_newsletters, id: false do |t|
      t.references :profile, index: true, foreign_key: true, null: false
      t.references :newsletter, index: true, foreign_key: true, null: false
    end
  end
end
