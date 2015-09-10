# == Schema Information
#
# Table name: companies
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Company < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  # Company name is used as subdomain
  
  # validation
  validates :name, uniqueness: true
  # validation
  
  # callback
  after_create :create_tenant
  # callback


  
  private
  
  def create_tenant
    Apartment::Tenant.create(name)
  end
end
