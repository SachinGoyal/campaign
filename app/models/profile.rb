# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_company_id  (company_id)
#

class Profile < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant

  #relaion
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :interest_areas ,class_name: "Attribute", join_table: "profiles_attributes"
  #relaion
  
  #validation
  validates_presence_of :name
  validates_inclusion_of :status, in: [true, false]  
  #validation

  # class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Profile.find(ids).each do |profile|
      	if action == 'delete'
          profile.destroy!
        else
          status = action == 'enable' ? 1 : 0
          profile.update(:status => status )
        end
      end
    end
  end
  # class methods

end
