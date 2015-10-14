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

  # validation
  validates_presence_of :campaign_id, :template_id,:name,:subject
  validates_inclusion_of :status, in: [true, false]
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
          newsletter.destroy!
        else
          status = action == 'enable' ? 1 : 0
          newsletter.update(:status => status )
        end
      end
    end
  end
  #class methods


end
