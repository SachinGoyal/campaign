class CreateAccesses < ActiveRecord::Migration
  def change
    create_table :accesses do |t|
      t.references :role, index: true, foreign_key: true, null: false
  	  t.references :function, index: true, foreign_key: true, null: false
      t.timestamps
    end   
  end  
end
