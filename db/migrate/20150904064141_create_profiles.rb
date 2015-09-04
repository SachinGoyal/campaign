class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :company, index: true, foreign_key: true
      t.string :name
      t.boolean :status
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
