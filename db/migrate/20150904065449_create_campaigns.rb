class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.text :description
      t.boolean :status
      t.integer :created_by
      t.integer :updated_by
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
