# == Schema Information
#
# Table name: templates
#
#  id         :integer          not null, primary key
#  name       :string
#  content    :text
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Template < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant#multitenant

  # validation
  validates_presence_of :name, :content
  validates_uniqueness_to_tenant :name
  validates_inclusion_of :status, in: [true, false]
  # validation

  #association
  belongs_to :user
  #association
end
