class AddCityToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :city, :string
    add_column :contacts, :country, :string
    add_column :contacts, :gender_id, :integer
  end
end
