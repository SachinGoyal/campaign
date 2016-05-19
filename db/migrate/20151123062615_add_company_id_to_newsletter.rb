class AddCompanyIdToNewsletter < ActiveRecord::Migration
  def change
    add_reference :newsletters, :company, index: true, foreign_key: true
  end
end
