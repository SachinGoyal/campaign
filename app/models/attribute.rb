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
  
  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  #validation
  validates_uniqueness_to_tenant :name, scope: :deleted_at
  validates :name, presence: true, length: {in: 2..150}
  validates :description, presence: true, length: {in: 2..255}
  validates_inclusion_of :status, in: [true, false]
  #validation

  #association
  belongs_to :company
  has_and_belongs_to_many :contacts, join_table: "contacts_attributes"
  has_and_belongs_to_many :profiles, join_table: "profiles_attributes"
  #association

  #before_destroy :check_contacts_and_profiles

  def check_contacts_and_profiles
    if contacts.any? or profiles.any?
      errors.add(:base, :contacts_exist)
      return false
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == "own"
      %w(name status created_at)
    else
      %w(name)
    end
  end
  

  #Class Methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Attribute.find(ids).each do |attribute|
        if action == 'delete'
          attribute.destroy
        else
          status = action == 'enable' ? 1 : 0
          attribute.update(:status => status )
        end
      end
    end
  end
  #Class Methods
end
