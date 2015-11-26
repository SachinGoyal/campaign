class CreateEmailServices < ActiveRecord::Migration
  def change
    create_table :email_services do |t|
      t.references :newsletter, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
