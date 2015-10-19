class AddCCandBccEmailToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :cc_email, :string
    add_column :newsletters, :bcc_email, :string
  end
end
