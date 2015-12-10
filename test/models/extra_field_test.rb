# == Schema Information
#
# Table name: extra_fields
#
#  id         :integer          not null, primary key
#  field_name :string
#  field_type :string
#  profile_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class ExtraFieldTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
