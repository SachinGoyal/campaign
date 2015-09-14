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
  acts_as_paranoid
end
