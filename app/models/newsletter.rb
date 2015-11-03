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
#  cc_email     :string
#  bcc_email    :string
#
# Indexes
#
#  index_newsletters_on_campaign_id  (campaign_id)
#  index_newsletters_on_template_id  (template_id)
#

class Newsletter < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant

  #scope
  default_scope {order('id DESC')}
  #scope
  

  # validation
  validates_presence_of :campaign, :template
  validates_presence_of :name, length: { in: 2..250}
  validates_presence_of :subject, length: { in: 2..255}
  validates_presence_of :from_name, length: { in: 2..150}
  validates_presence_of :from_address, length: { in: 2..250}
  # validation

  #association
  belongs_to :campaign
  belongs_to :template
  #association

  #class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Newsletter.find(ids).each do |newsletter|
        if action == 'delete'
          newsletter.destroy
        end
      end
    end
  end
  #class methods


end
