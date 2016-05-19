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
  validates :name, uniqueness: {scope: :deleted_at}, 
                   presence: true, 
                   # format: { with: /\A[a-zA-Z0-9 ]+\z/, 
                   #           message: I18n.t('activerecord.errors.models.campaign.attributes.name.format')},
                   length: {in: 2..150}

  validates :description, presence: true#, 
                          # format: { with: /\A[a-zA-Z0-9 ]+\z/, 
                          #           message: 'Can only contain alphanumeric and space.'},
                          # length: {in: 2..255}
  validates_inclusion_of :status, in: [true, false]
  #validation

  #callbacks
  before_destroy :check_newsletter
  #callbacks

  # relation
  has_many :newsletters, :dependent => :destroy
  # relation
  
  #delegate
  delegate :username, to: :user, prefix: true
  #delegate

  #ransack
  def self.load_custom_attributes
    ransacker :created_at do
      Arel::Nodes::SqlLiteral.new("date(campaigns.created_at)")
    end
  end
  
  def self.ransackable_attributes(auth_object = nil)
    super & %w(name  status created_at)
  end
  #ransack


  def check_newsletter
    if newsletters.any? and newsletters.map(&:editable_or_deletable?).include?(false)
      errors.add(:base, :newsletters_exist)
      return false
    end
  end

  #class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Campaign.find(ids).each do |campaign|
        if action == 'delete'
          campaign.destroy
        else
          status = action == 'enable' ? true : false
          campaign.update(:status => status )
        end
      end
    end
  end
  #class methods
end