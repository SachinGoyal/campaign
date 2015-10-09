class ProfilesAttributes < ActiveRecord::Migration
  def change
  	create_table :profiles_attributes, id: false do |t|
      t.references :profile, index: true, foreign_key: true, null: false
      t.references :attribute, index: true, foreign_key: true, null: false
    end
  end
end
