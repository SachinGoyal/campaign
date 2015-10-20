# == Schema Information
#
# Table name: companies
#
#  id          :integer          not null, primary key
#  name        :string
#  free_emails :integer
#  status      :boolean
#  created_by  :integer
#  updated_by  :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  subdomain   :string
#

class Company < ActiveRecord::Base
  
  acts_as_paranoid  # Soft Delete


  # Company name is used as subdomain
  # acts_as_universal_and_determines_tenant
  
  # validation
  validates :name, uniqueness: true, presence: true, format: { with: /\A[a-zA-Z][a-zA-Z ]+\z/}, length: {in: 2..50}
  validates :free_emails, numericality: {greater_than_or_equal_to: 0}, allow_blank: true
  # validates_presence_of :company_id, :if => lambda { |o| o.role_id == Role.superadmin.first.id }
  # validates_presence_of :users 
  validates_inclusion_of :status, in: [true, false]
  validates_numericality_of :free_emails,  :greater_than => 0, :less_than => 1000
  # validation

  # relations
  has_many :roles, :dependent => :restrict_with_error
  has_many :users, :dependent => :restrict_with_error
  belongs_to :creator, class_name: "User", foreign_key: :created_by
  belongs_to :updator, class_name: "User", foreign_key: :updated_by
  # relations
  
  #nested attribute
  accepts_nested_attributes_for :users
  #nested attribute
   
  #callback
  before_create :set_subdomain
  after_create :create_role
  #callback

  #ransack

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(companies.created_at)")
  end
  
  def self.ransackable_attributes(auth_object = nil)
    super & %w(name subdomain created_at)
  end

  #ransack


  #class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Company.find(ids).each do |company|
        if action == 'delete'
          company.destroy!
        else
          status = action == 'enable' ? 1 : 0
          company.update(:status => status )
        end
      end
    end
  end
  #class methods

  def set_subdomain
    self.subdomain = self.name.gsub(' ', '').downcase
  end

  def create_role
    role = Role.create(name: COMPANY_ADMIN,company_id: self.id)
    users.first.update(role_id: role.id)
  end
end
