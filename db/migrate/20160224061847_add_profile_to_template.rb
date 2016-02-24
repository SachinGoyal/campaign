class AddProfileToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :profile_id, :integer
  end
end
