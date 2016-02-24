# == Schema Information
#
# Table name: profiles
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  name        :string
#  status      :boolean
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#
# Indexes
#
#  index_profiles_on_company_id  (company_id)
#

class Profile < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant

  #validation
  validates :name, presence: true, length: { in: 2..250}
  validates_uniqueness_to_tenant :name
  validates_inclusion_of :status, in: [true, false]  
  #validation

  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  
  #callback
  before_destroy :check_contacts
  before_destroy :used_in_unsent_newsletter
  before_update :used_in_unsent_newsletter_update
  #callback

  #relation
  has_one :template
  has_many :contacts
  has_many :extra_fields, :inverse_of => :profile
  has_many :newsletter_emails
  has_many :newsletters, :through => :newsletter_emails
  #relation

  after_update :update_contact_extra_fields

  accepts_nested_attributes_for :extra_fields,
    :allow_destroy => true,
    :reject_if     => :all_blank

  def used_in_unsent_newsletter_update
    if status_changed? and !status and newsletter_emails.count > 0
      errors.add(:base, :newsletters_exist)
      return false
    end
  end

  def used_in_unsent_newsletter
    if newsletter_emails.count > 0
      errors.add(:base, :newsletters_exist)
      return false
    end
  end

  def check_contacts
    if contacts.count > 0
      errors.add(:base, :contacts_exist)
      return false
    end
  end

  def update_contact_extra_fields
    profile_fields = extra_fields.map(&:field_name)
    if contacts.any? #&& contacts.first.extra_fields.any?
      contact_fields = contacts.first.extra_fields.try(:keys) || []      
      fields_to_be_added = profile_fields - contact_fields
      fields_to_be_deleted = contact_fields - profile_fields
      contacts.each do |contact|
        contact.extra_fields = {} if !contact.extra_fields
        fields_to_be_added.each do |fld|
          contact.extra_fields[fld] = ""
        end
        contact.extra_fields.except!(*fields_to_be_deleted)
        contact.save
      end
    end
  end

  # class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Profile.find(ids).each do |profile|
      	if action == 'delete'
          profile.destroy
        else
          status = action == 'enable' ? 1 : 0
          profile.update(:status => status )
        end
      end
    end
  end
  # class methods

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == "own"
      %w(name created_at status)
    else
      %w(name)
    end
  end

end
