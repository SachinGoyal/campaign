# == Schema Information
#
# Table name: templates
#
#  id              :integer          not null, primary key
#  name            :string
#  content         :text
#  status          :boolean
#  created_by      :integer
#  updated_by      :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  company_id      :integer
#  template_images :json
#
# Indexes
#
#  index_templates_on_company_id  (company_id)
#

require 'test_helper'

class TemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
