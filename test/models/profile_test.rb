# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  name        :string
#  status      :boolean
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_profiles_on_company_id  (company_id)
#

require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
