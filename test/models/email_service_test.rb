# == Schema Information
#
# Table name: email_services
#
#  id                       :integer          not null, primary key
#  newsletter_id            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  list_id                  :string
#  campaign_id              :string
#  company_id               :integer
#  opens_total              :integer
#  unique_opens             :integer
#  clicks_total             :integer
#  unique_clicks            :integer
#  unique_subscriber_clicks :integer
#  hard_bounces             :integer
#  soft_bounces             :integer
#  unsubscribed             :integer
#  forwards_count           :integer
#  forwards_opens           :integer
#  emails_sent              :integer
#  abuse_reports            :integer
#  send_at                  :datetime
#  template_id              :integer
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
