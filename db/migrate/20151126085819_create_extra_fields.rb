class CreateExtraFields < ActiveRecord::Migration
  def change
    create_table :extra_fields do |t|
      t.string :field_name
      t.references :profile
      t.timestamps null: false
    end
  end
end
