# == Schema Information
#
# Table name: companies
#
#  id           :integer          not null, primary key
#  name         :string
#  free_emails  :integer
#  status       :boolean
#  created_by   :integer
#  updated_by   :integer
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  subdomain    :string
#  company_logo :string
#

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
