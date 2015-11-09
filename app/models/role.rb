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
#  status     :boolean          default(TRUE)
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
  validates :name, presence: true, length: { in: 2..50 }, format: { with: /\A[a-zA-Z][a-zA-Z0-9 ]+\z/, 
                             message: 'Can only contain alphanumeric and space. Must begin with a character'}

  #validates_uniqueness_to_tenant :name
  validates_uniqueness_of :name, :scope => :company_id  
  #validation

  #callback
  before_update :check_companyadmin
  before_destroy :check_generic_companyadmin
  #callback

  # Association
  belongs_to :company
  has_many :users, :dependent => :destroy

  has_many :accesses, dependent: :destroy
  has_many :functions, through: :accesses
  # Association
  
  accepts_nested_attributes_for :functions

  #scope
  # default_scope {order('id DESC') }
  scope :company_admin, -> { where(name: COMPANY_ADMIN) }
  scope :admin, -> { where(name: admin) }
  scope :editable, -> { where(editable: true)}
  scope :non_editable, -> { where(editable: false)}
  #scope


  class << self

    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Role.find(ids).each do |role|
        if action == 'delete'
          role.destroy
        else
          status = action == 'enable' ? 1 : 0
          role.update(:status => status )
        end
      end
    end

  end

  def check_generic_companyadmin
    if self.id == COMPANY_ADMIN_ID
      errors[:base] << "Cannot delete Company admin"
      return false
    end
  end

  def check_companyadmin
    name == COMPANY_ADMIN if !editable?
  end

  
  # change permission respective to generic company admin
  def assign_permission
    company_admin,*company_admin_all = Role.company_admin.reorder("id ASC")
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
