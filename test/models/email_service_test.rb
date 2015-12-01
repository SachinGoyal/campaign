# == Schema Information
#
# Table name: email_services
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_id       :string
#  campaign_id   :string
#
# Indexes
#
#  index_email_services_on_newsletter_id  (newsletter_id)
#

require 'test_helper'

class EmailServiceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
