class AddHstoreToContact < ActiveRecord::Migration
  def change
  	enable_extension :hstore
  	add_column :contacts, :extra_fields, :hstore
  end
end
