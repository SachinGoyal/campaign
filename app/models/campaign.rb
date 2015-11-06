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

  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant

  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope
  

  #validation
  validates :name, uniqueness: true, 
                   presence: true, 
                   format: { with: /\A[a-zA-Z0-9 ]+\z/, 
                             message: 'Can only contain alphanumeric and space.'},
                   length: {in: 2..155}

  validates :description, 
                   presence: true, 
                   format: { with: /\A[a-zA-Z0-9 ]+\z/, 
                             message: 'Can only contain alphanumeric and space.'},
                   length: {in: 2..155}
  validates_inclusion_of :status, in: [true, false]
  #validation

  # relation
  has_many :newsletters
  # relation
  
  #delegate
  delegate :username, to: :user, prefix: true
  #delegate

  #class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Campaign.find(ids).each do |campaign|
        if action == 'delete'
          campaign.destroy
        else
          status = action == 'enable' ? 1 : 0
          campaign.update(:status => status )
        end
      end
    end
  end
  #class methods

end
