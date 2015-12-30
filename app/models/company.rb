# == Schema Information
#
# Table name: companies
#
#  id           :integer          not null, primary key
#  name         :string
#  free_emails  :integer
#  status       :boolean
#  created_by   :integer
#  updated_by   :integer
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subdomain    :string
#  company_logo :string
#

class Company < ActiveRecord::Base
  mount_uploader :company_logo, AvatarUploader
  acts_as_paranoid  # Soft Delete

  #scope
  default_scope {order('id DESC')}
  #scope
  
  
  # validation
  validates :name, uniqueness: true, 
                   presence: true, 
                   format: { with: /\A[a-zA-Z0-9 ]+\z/, 
                             message: I18n.t('activerecord.errors.models.company.attributes.name.format')},
                   length: {in: 2..255}

  validates :free_emails, numericality: {less_than_or_equal_to: 99999, greater_than_or_equal_to: 0, :message => "Enter values between 0 and 99999"}, 
                          allow_blank: true

  # validates_presence_of :company_id, :if => lambda { |o| o.role_id == Role.superadmin.first.id }
  # validates_presence_of :users 
  validates_inclusion_of :status, in: [true, false]
  # validation

  #callback
  before_create :set_subdomain, :check_email
  # after_create :create_role
  #callback

  # relations
  has_many :users, :dependent => :destroy
  has_many :roles, :dependent => :destroy

  belongs_to :creator, class_name: "User", foreign_key: :created_by
  belongs_to :updator, class_name: "User", foreign_key: :updated_by
  # relations
  
  #nested attribute
  accepts_nested_attributes_for :users
  #nested attribute
   

  #ransack
  def self.load_custom_attributes
    ransacker :created_at do
      Arel::Nodes::SqlLiteral.new("date(companies.created_at)")
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    super & %w(name subdomain created_at status free_emails)
  end
  #ransack


  #class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Company.find(ids).each do |company|
        if action == 'delete'
          company.destroy
        else
          status = action == 'enable' ? 1 : 0
          company.update(:status => status )
        end
      end
    end
  end
  #class methods

  def check_email
     self.free_emails = Setting.first.free_emails if !free_emails.present?
  end

  def set_subdomain
    self.subdomain = self.name.strip.gsub(' ', '_').downcase
  end

  def create_role
    role = roles.new(name: COMPANY_ADMIN , editable: false)
    role.save
    role.assign_permission if role.name == COMPANY_ADMIN
    users.first.update(role_id: role.id)
  end
end
