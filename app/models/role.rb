# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  status     :boolean
#  editable   :boolean          default(TRUE)
#
# Indexes
#
#  index_roles_on_company_id  (company_id)
#

class Role < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete
  
  acts_as_tenant(:company) #multitenant

  #validation
  validates :name, presence: true, format: { with: /\A[a-zA-Z][a-zA-Z0-9 ]+\z/, 
                             message: 'Can only contain alphanumeric and space. Must begin with a character'}

  #validates_uniqueness_to_tenant :name
  validates_uniqueness_of :name, :scope => :company_id  
  #validation

  # Association
  belongs_to :company
  has_many :users, :dependent => :destroy

  has_many :accesses, dependent: :destroy
  has_many :functions, through: :accesses
  # Association
  
  accepts_nested_attributes_for :functions

  #scope
  default_scope {order('id') }
  scope :company_admin, -> { where(name: COMPANY_ADMIN) }
  scope :admin, -> { where(name: admin) }
  #scope

  #callback
  before_update :check_companyadmin
  #callback

  def check_companyadmin
    name == COMPANY_ADMIN if !editable?
  end

  
  # change permission respective to generic company admin
  def assign_permission
    company_admin,*company_admin_all = Role.company_admin
    functions = company_admin.try(:function_ids) 
    if company_admin_all.any?
      company_admin_all.each do |c_admin|
        c_admin.function_ids = functions
      end
    end
  end

  def name=(value)
    write_attribute(:name, value.downcase)
  end

  private
    def check_admin
      if self.id == ADMIN
        errors.add :base, "Cannot delete super admin role"
        return false
      end
    end
end
