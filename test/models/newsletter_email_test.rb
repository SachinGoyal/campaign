# == Schema Information
#
# Table name: newsletter_emails
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  profile_id    :integer
#  emails        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sample        :boolean
#  from_contacts :boolean
#  sent          :boolean          default(FALSE)
#

require 'test_helper'

class NewsletterEmailTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
