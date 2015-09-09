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
  has_many :campeigns
  belongs_to :role
  before_save :set_role
  # relations

  # class function
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end     
  # class function

  def set_role
     self.role = Role.first
  end
end
