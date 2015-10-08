# == Schema Information
#
# Table name: attributes
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  name        :string
#  description :text
#  status      :boolean
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_attributes_on_company_id  (company_id)
#

class Attribute < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete
  
  acts_as_tenant(:company) #multitenant
  
  #validation
  validates_presence_of :name
  validates_inclusion_of :status, in: [true, false]
  #validation

  #association
  belongs_to :company
  #association

end
