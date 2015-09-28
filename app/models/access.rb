# == Schema Information
#
# Table name: accesses
#
#  id          :integer          not null, primary key
#  role_id     :integer          not null
#  function_id :integer          not null
#  created_at  :datetime
#  updated_at  :datetime
#
# Indexes
#
#  index_accesses_on_function_id  (function_id)
#  index_accesses_on_role_id      (role_id)
#

class Access < ActiveRecord::Base
  
  #acts_as_paranoid #soft delete
  
  #acts_as_tenant(:company) #multitenant

  # relation
  belongs_to :function
  belongs_to :role
  # relation
  
  #validation
  validates :role, uniqueness: {scope: :function}#, allow_blank: true
  validates :role, :function, presence: true                       
  #validation
  
end
