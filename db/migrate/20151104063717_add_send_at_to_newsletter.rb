class AddSendAtToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :send_at, :datetime
  end
end
