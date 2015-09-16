# == Schema Information
#
# Table name: companies
#
#  id          :integer          not null, primary key
#  name        :string
#  free_emails :integer
#  status      :boolean
#  created_by  :integer
#  updated_by  :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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

  # relations
  has_many :users
  accepts_nested_attributes_for :users
  # relations
    
  private
  
  def create_tenant
    #Apartment::Tenant.create(name)
  end
end
