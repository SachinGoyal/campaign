# == Schema Information
#
# Table name: settings
#
#  id                   :integer          not null, primary key
#  site_title           :string
#  free_emails          :string
#  admin_email          :string
#  admin_footer_content :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class SettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
