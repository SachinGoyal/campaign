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
  validates_uniqueness_to_tenant :name
  validates :name, presence: true, length: {in: 2..50}
  validates_inclusion_of :status, in: [true, false]
  #validation

  #association
  belongs_to :company
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :profiles
  #association

  #Class Methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Attribute.find(ids).each do |attribute|
        if action == 'delete'
          attribute.destroy!
        else
          status = action == 'enable' ? 1 : 0
          attribute.update(:status => status )
        end
      end
    end
  end
  #Class Methods


end
