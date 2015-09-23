# == Schema Information
#
# Table name: campaigns
#
#  id          :integer          not null, primary key
#  name        :string
#  description :text
#  status      :boolean
#  created_by  :integer
#  updated_by  :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  company_id  :integer
#
# Indexes
#
#  index_campaigns_on_company_id  (company_id)
#

class Campaign < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  # relation
  belongs_to :user
  # relation
  
  #delegate
  delegate :username, to: :user, prefix: true
  #delegate

end
