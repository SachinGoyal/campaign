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

  #validation
    validates_presence_of :name,:status,:first_name,:email
    validates_uniqueness_of :email
  #validation

  
  #relation
  has_and_belongs_to_many :profiles
  #relation

  # class methods
  class << self

    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Contact.find(ids).each do |contact|
        if action == 'delete'
          contact.destroy!
        else
          status = action == 'enable' ? 1 : 0
          contact.update(:status => status )
        end
      end
    end

    def accessible_attributes
      ["first_name", "last_name", "email", "company_id"]
    end
    
    def import_records(file, profile_id = nil)
      profile = Profile.find(profile_id)
      CSV.foreach(file.path, headers: true) do |row|  
        (profile ? profile.contacts : Contact).create(row.to_hash) 
      end      
    end
  
  end
  # class methods
end
