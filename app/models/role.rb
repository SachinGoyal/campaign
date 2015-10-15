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
#
# Indexes
#
#  index_roles_on_company_id  (company_id)
#

class Role < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete
  
  acts_as_tenant(:company) #multitenant

  #validation
  validates :name, presence: true, format: { with: /\A[[:word:][:blank:]]+\z/}
  validates_uniqueness_to_tenant :name
  #validation

  # Association
  belongs_to :company
  has_many :users, :dependent => :restrict_with_error
  
  has_many :accesses, dependent: :destroy
  has_many :functions, through: :accesses
  # Association
  
  accepts_nested_attributes_for :functions

  #scope
  default_scope {order('name') }
  scope :company_admin, -> { where(name: COMPANY_ADMIN) }
  scope :admin, -> { where(name: admin) }
  #scope

  

  def name=(value)
    write_attribute(:name, value.downcase)
  end

  private
    def check_admin
      if self.id == ADMIN
        errors.add :base, "no puedes eliminar el rol admin"
        return false
      end
    end
end
