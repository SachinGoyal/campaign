# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  company_id :integer
#  first_name :string
#  last_name  :string
#  email      :string
#  status     :boolean          default(TRUE)
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string
#  country    :string
#  gender     :string
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
