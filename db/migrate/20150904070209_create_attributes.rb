class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.references :company, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :status

      t.timestamps null: false
    end
  end
end
