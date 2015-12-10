# == Schema Information
#
# Table name: contacts
#
#  id           :integer          not null, primary key
#  company_id   :integer
#  email        :string
#  status       :boolean          default(TRUE)
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  extra_fields :hstore
#  profile_id   :integer
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#

require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
