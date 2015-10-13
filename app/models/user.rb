# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  role_id                :integer          not null
#  username               :string           default(""), not null
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  company_id             :integer
#  status                 :boolean
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete
  
  acts_as_tenant(:company) #multitenant#multitenant
  
  self.per_page = 10

    
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  # devise 
  attr_accessor :login
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # devise 
  
  # validation
  validates :username, presence: true, uniqueness: true, length: { in: 4..20 }
  # validation
  
  # relations
  has_many :campaigns
  belongs_to :role
  belongs_to :company
  # relations
  
  # callback
  # callback

  #ransack
  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(users.created_at)")
  end

  def self.ransackable_attributes(auth_object = nil)
    super & %w(username email created_at)
  end
  #ransack

  # class function
  class << self
    def find_first_by_auth_conditions(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        conditions.permit! if conditions.class.to_s == "ActionController::Parameters"
        where(conditions).first
      end
    end  
  end   
  
  # class function
  
  def is_admin?
    role.name == 'admin'
  end

  def is_companyadmin?
    role.name == COMPANY_ADMIN
  end

  private


  # def self.ransackable_scopes(auth_object = nil)
  #   if auth_object.try(:admin?)
  #     # allow admin users access to all three methods
  #     %i(active hired_since salary_gt)
  #   else
  #     # allow other users to search on active and hired_since only
  #     %i(auth_object.company.users)
  #   end
  # end


end
