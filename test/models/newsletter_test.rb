# == Schema Information
#
# Table name: newsletters
#
#  id            :integer          not null, primary key
#  campaign_id   :integer
#  template_id   :integer
#  name          :string
#  subject       :string
#  from_name     :string
#  from_address  :string
#  reply_email   :string
#  created_by    :integer
#  updated_by    :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cc_email      :string
#  bcc_email     :string
#  send_at       :datetime
#  auto_response :string
#  company_id    :integer
#  user_id       :integer
#  scheduled_at  :datetime
#  all_emails    :string
#
# Indexes
#
#  index_newsletters_on_campaign_id  (campaign_id)
#  index_newsletters_on_company_id   (company_id)
#  index_newsletters_on_template_id  (template_id)
#

require 'test_helper'

class NewsletterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
