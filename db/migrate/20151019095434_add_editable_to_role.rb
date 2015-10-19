class AddEditableToRole < ActiveRecord::Migration
  def change
    add_column :roles, :editable, :boolean
  end
end
