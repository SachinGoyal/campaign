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
  belongs_to :function
  belongs_to :role

  validates_uniqueness_of :role_id, scope: :function_id, allow_blank: true

  # validates :role_id, :function_id, :presence => true

  # <audits>
  # audited
  # audited :associated_with => :function
  # audited :associated_with => :role
  # </audits>

end
