# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  role_id                :integer
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
#  image                  :string
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

  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope
    
  self.per_page = 10
  mount_uploader :image, ImageUploader
    
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  # devise 
  attr_accessor :login
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # devise 
  
  # validation
  validates :username, presence: true, uniqueness: true, length: { in: 4..50 }, format: { with: /\A[a-zA-Z][a-zA-Z0-9 ]+\z/}
  validates :role_id, presence: true
  # validates_presence_of :company_id, :if => lambda { |o| o.role_id != Role.superadmin.first.id }
  # validation
  
  # relations
  has_many :campaigns
  belongs_to :role
  belongs_to :company
  # relations
  
  # callback
  before_destroy :check_company_admin
  # callback

  #ransack
  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(users.created_at)")
  end

  def check_company_admin
    # if role.name == COMPANY_ADMIN
    #   errors[:base] << "Cannot delete user with company admin role"
    #   return false
    # end
    if role.name == SUPERADMIN
      errors[:base] << "Cannot delete super admin"
      return false
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    super & %w(username email created_at)
  end
  #ransack

  # class function
  class << self
    
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      User.find(ids).each do |user|
        if action == 'delete'
          unless user.role.name == COMPANY_ADMIN
            user.destroy
          end
        else
          status = action == 'enable' ? 1 : 0
          user.update(:status => status )
        end
      end
    end

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

  def active?
    status?
  end

  def active_for_authentication? 
    super && active? 
  end 

  def inactive_message 
    if !active? 
      :not_approved 
    else 
      super # Use whatever other message 
    end 
  end 

  def self.send_reset_password_instructions(attributes={})
    recoverable = find_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    if !recoverable.active?
      recoverable.errors[:base] << I18n.t("devise.failure.not_approved")
    elsif recoverable.persisted?
      recoverable.send_reset_password_instructions
    end
    recoverable
  end 

  # class function

  def active_for_authentication?
    super && status == true
  end

  def is_admin?
     role.id == ADMIN_ID
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
