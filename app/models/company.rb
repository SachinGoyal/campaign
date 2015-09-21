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
#

class Company < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  # Company name is used as subdomain
  
  # relations
  has_many :users
  accepts_nested_attributes_for :users
  belongs_to :creator, class_name: "User", foreign_key: :created_by
  belongs_to :updator, class_name: "User", foreign_key: :updated_by
  # relations

  # validation
  validates :name, uniqueness: true
  validates_presence_of :users  
  # validation
  
end
