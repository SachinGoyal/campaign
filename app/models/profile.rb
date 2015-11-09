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

  #validation
  validates :name, presence: true, length: { in: 2..250}
  validates_uniqueness_to_tenant :name
  validates_inclusion_of :status, in: [true, false]  
  #validation

  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  
  #callback
  before_destroy :check_contacts
  #callback

  #relation
  has_and_belongs_to_many :contacts
  has_and_belongs_to_many :interest_areas, class_name: "Attribute", join_table: "profiles_attributes"
  has_many :newsletter_emails
  has_many :newsletters, :through => :newsletter_emails
  #relation
  


  def check_contacts
    if contacts.count > 0
      errors[:base] << "Cannot delete Profile while Contacts exist"
      return false
    end
  end

  # class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Profile.find(ids).each do |profile|
      	if action == 'delete'
          profile.destroy
        else
          status = action == 'enable' ? 1 : 0
          profile.update(:status => status )
        end
      end
    end
  end
  # class methods

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(contacts.created_at)")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w(name created_at)
  end

end
