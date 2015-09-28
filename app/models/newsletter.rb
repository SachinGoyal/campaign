# == Schema Information
#
# Table name: newsletters
#
#  id           :integer          not null, primary key
#  campaign_id  :integer
#  template_id  :integer
#  name         :string
#  subject      :string
#  from_name    :string
#  from_address :string
#  reply_email  :string
#  created_by   :integer
#  updated_by   :integer
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_newsletters_on_campaign_id  (campaign_id)
#  index_newsletters_on_template_id  (template_id)
#

class Newsletter < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant

  #association
  belongs_to :campaign
  belongs_to :template
  #association

end
