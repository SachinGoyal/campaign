class AddCompanyIdToCampaign < ActiveRecord::Migration
  def change
    add_reference :campaigns, :company, index: true, foreign_key: true
    #add_reference :roles, :company, index: true, foreign_key: true

  end
end
