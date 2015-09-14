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

require 'test_helper'

class FunctionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
