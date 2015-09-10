class FunctionsRoles < ActiveRecord::Migration
  def change
  	create_table :functions_roles, id: false do |t|
      t.references :function, index: true, foreign_key: true, null: false
      t.references :role, index: true, foreign_key: true, null: false
    end
  end
end
