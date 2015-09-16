# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  role_id                :integer          not null
#  user_type              :string
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
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  
  # devise 
  attr_accessor :login
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  # devise 
  
  # validation
  validates_uniqueness_of :username
  validates_presence_of :username
  validates :username, length: { in: 4..20 }
  # validation
  
  # relations
  has_many :campaigns
  belongs_to :role
  before_save :set_role
  # relations

  # class function
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      conditions.permit! if conditions.class.to_s == "ActionController::Parameters"
      where(conditions).first
    end
  end     
  # class function

  def set_role
    if Role.first.present?
      self.role = Role.first
    else
      Role.create(:name => 'Guest')
    end
      self.role = Role.first
  end


  def is_admin?
    user.role.name == 'admin'
  end


end
