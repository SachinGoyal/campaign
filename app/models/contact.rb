# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  company_id :integer
#  first_name :string
#  last_name  :string
#  email      :string
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#

class Contact < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant
  
  #relation
  has_and_belongs_to_many :profiles
  #relation

  def self.import_records(file, profile_id = nil)
  	profile = Profile.find(profile_id)
  	CSV.foreach(file.path, headers: true) do |row|  
    	(profile ? profile.contacts : Contact).create(row.to_hash) 
  	end      
  end
end
