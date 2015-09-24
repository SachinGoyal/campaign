# == Schema Information
#
# Table name: profiles
#
#  id         :integer          not null, primary key
#  company_id :integer
#  name       :string
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profiles_on_company_id  (company_id)
#

class Profile < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  validates :name, presence: true
  has_and_belongs_to_many :contacts
end
