class AddUserIdToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :user_id, :integer
  end
end
