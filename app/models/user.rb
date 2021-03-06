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
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  invitation_token       :string
#  invitation_created_at  :datetime
#  invitation_sent_at     :datetime
#  invitation_accepted_at :datetime
#  invitation_limit       :integer
#  invited_by_id          :integer
#  invited_by_type        :string
#  invitations_count      :integer          default(0)
#
# Indexes
#
#  index_users_on_company_id            (company_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email)
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username)
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
  devise :invitable, :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable
  # devise 
  validate :remove_old_email_validation_error
  # validation
  validates :username, presence: true, length: { in: 4..50 }
  validates_uniqueness_to_tenant :email
  validates_uniqueness_to_tenant :username
  validates :email, presence: true
  validates_format_of :email, :with => Devise.email_regexp

  # , format: { with: /\A[a-zA-Z0-9 ]+\z/, :message => I18n.t('activerecord.errors.models.user.attributes.username.format')}
  validates :role_id, presence: true

  # validation
  
  # callback
  before_destroy :check_company_admin
  # callback

  # relations
  has_many :campaigns
  belongs_to :role
  belongs_to :company
  # relations
  

  #ransack
  def self.load_custom_attributes
    ransacker :created_at do
      Arel::Nodes::SqlLiteral.new("date(users.created_at)")
    end
  end

  def check_company_admin
    # if role.name == COMPANY_ADMIN
    #   errors[:base] << "Cannot delete user with company admin role"
    #   return false
    # end
    if role.name == SUPERADMIN
      errors.add(:base, :delete_admin)
      return false
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    super & %w(username email created_at status)
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

  def confirmation_required?
    false
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

  def remove_old_email_validation_error
    errors.delete(:email)
  end


  def active_for_authentication?
    if is_admin?
      super 
    else
      super && status
    end
  end

  def is_admin?
     role.id == ADMIN_ID
  end

  def is_companyadmin?
    role.name == COMPANY_ADMIN
  end
end
