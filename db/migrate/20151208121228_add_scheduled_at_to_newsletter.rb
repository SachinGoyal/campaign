class AddScheduledAtToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :scheduled_at, :datetime
  end
end
