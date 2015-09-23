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
  # Soft Delete
  acts_as_paranoid
  # Soft Delete

  # Association
  has_many :users
  has_many :accesses, dependent: :destroy
  has_many :functions, through: :accesses
  # Association

  #validation
  validates :name, presence: true, uniqueness: true, format: { with: /\A[[:word:][:blank:]]+\z/}
  #validation

  #scope
  default_scope {order('name') }
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
