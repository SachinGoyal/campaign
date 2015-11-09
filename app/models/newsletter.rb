# == Schema Information
#
# Table name: newsletters
#
#  id            :integer          not null, primary key
#  campaign_id   :integer
#  template_id   :integer
#  name          :string
#  subject       :string
#  from_name     :string
#  from_address  :string
#  reply_email   :string
#  created_by    :integer
#  updated_by    :integer
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cc_email      :string
#  bcc_email     :string
#  send_at       :datetime
#  auto_response :string
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
  validates_presence_of :campaign_id, :template_id

  validates :name, presence: true, length: { in: 2..250 }
  validates :subject, presence: true, length: { in: 2..255 }
  validates :from_name, presence: true, length: { in: 2..150 }
  validates :from_address, presence: true, format: {with: Devise.email_regexp}
  validates_format_of :reply_email, :cc_email, :bcc_email, :with => Devise.email_regexp, :allow_blank => true
  # validation

  #callback
  before_update :mark_children_for_removal
  #callback

  #association
  belongs_to :campaign
  belongs_to :template
  has_many :newsletter_emails, inverse_of: :newsletter
  has_many :profiles, :through => :newsletter_emails

  accepts_nested_attributes_for :newsletter_emails, reject_if: proc { |attrs| attrs['profile_id'].blank? and attrs['emails'].blank? and attrs['id'].blank? }, :allow_destroy => true
  #association


  def mark_children_for_removal
    newsletter_emails.each do |child|
      child.mark_for_destruction if child.emails.blank? and child.profile_id.blank?
    end
  end

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(newsletters.created_at)")
  end
  
  def self.ransackable_attributes(auth_object = nil)
    %w(name subject created_at)
  end

  def sent?
    if send_at
      send_at <= Time.now
    else
      true
    end
  end

  def editable_or_deletable?
    sent?
    false
  end

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

  def all_emails
    newsletter_emails.map(&:emails).flatten.uniq.join(", ")
  end
end
