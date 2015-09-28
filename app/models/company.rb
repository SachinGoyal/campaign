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
  
  # relations
  has_many :roles
  has_many :users
  belongs_to :creator, class_name: "User", foreign_key: :created_by
  belongs_to :updator, class_name: "User", foreign_key: :updated_by
  # relations
  
  #nested attribute
  accepts_nested_attributes_for :users
  #nested attribute

  # validation
  validates :name, uniqueness: true
  validates_presence_of :users  
  # validation
   
  #callback
  before_create :set_subdomain
  #callback

  def set_subdomain
    self.subdomain = self.name
  end
end
