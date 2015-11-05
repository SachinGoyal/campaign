class AddAutoResponseToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :auto_response, :string
  end
end
