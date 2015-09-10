class CreateFunctions < ActiveRecord::Migration
  def change
    create_table :functions do |t|
      t.string :controller
      t.string :action
      t.string :agroup
      t.datetime :deleted_at

      t.timestamps null: false
    end
  end
end
