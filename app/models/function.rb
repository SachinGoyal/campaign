# == Schema Information
#
# Table name: functions
#
#  id         :integer          not null, primary key
#  controller :string
#  action     :string
#  agroup     :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Function < ActiveRecord::Base
  
  # Soft Delete
    # acts_as_paranoid
  # Soft Delete
  
  # validation
  validates :controller, :action, presence: true
  validates_uniqueness_of :controller, scope: :action
  # validation

  #association
  has_many :accesses
  has_many :roles, through: :accesses
  #association
  
  
  #scope
  scope :order_by_controller, ->{ order("controller ASC, action ASC") }
  #scope



  # scope :function, where(published: true)


  # <audits>
  # has_associated_audits
  # </audits>

end
