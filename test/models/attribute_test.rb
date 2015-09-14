# == Schema Information
#
# Table name: attributes
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  name        :string
#  description :text
#  status      :boolean
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class AttributeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
