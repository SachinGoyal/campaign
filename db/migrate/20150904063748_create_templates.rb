class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.text :content
      t.boolean :status
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
