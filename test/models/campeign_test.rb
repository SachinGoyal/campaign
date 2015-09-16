# == Schema Information
#
# Table name: campeigns
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  name        :string
#  description :text
#  status      :boolean
#  created_by  :integer
#  updated_by  :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_campeigns_on_user_id  (user_id)
#

require 'test_helper'

class CampeignTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
