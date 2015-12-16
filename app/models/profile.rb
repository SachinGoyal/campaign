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
  before_update :used_in_unsent_newsletter, if: :status_changed?
  after_update :update_contact_extra_fields
  #callback

  #relation
  has_many :contacts
  has_many :extra_fields, :inverse_of => :profile
  has_many :newsletter_emails
  has_many :newsletters, :through => :newsletter_emails
  #relation

  accepts_nested_attributes_for :extra_fields,
    :allow_destroy => true,
    :reject_if     => :all_blank


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
    profile_field = extra_fields.map(&:field_name)
    if contacts.any? #&& contacts.first.extra_fields.any?
      contact_field = contacts.first.extra_fields.keys 
      profile_field.each do |field|
        if !contact_field.include?(:field)
          contacts.each do |contact|
            contact.extra_fields[field] = ""
            contact.save
          end
        end
      end

      contact_field.each do |field|
        if !profile_field.include?(:field)
          contacts.each do |contact|
            contact.extra_fields.delete(field)
            contact.save
          end
        end
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

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(profiles.created_at)")
  end

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == "own"
      %w(name created_at status)
    else
      %w(name)
    end
  end

end
