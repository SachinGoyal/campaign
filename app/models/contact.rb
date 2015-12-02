# == Schema Information
#
# Table name: contacts
#
#  id           :integer          not null, primary key
#  company_id   :integer
#  email        :string
#  status       :boolean          default(TRUE)
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  extra_fields :hstore
#  profile_id   :integer
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#

class Contact < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant
  # GENDERS = ['male', 'female']

  #store_accessor :extra_fields
  
  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  #validation
  validates_presence_of :email, length: { in: 3..255}
  # validates_presence_of :profile_ids, message: 'Please select atleast one'
  validates_uniqueness_to_tenant :email
  validates_format_of :email, :with => Devise.email_regexp
  validates_inclusion_of :status, in: [true, false]
  # validates_inclusion_of :gender, in: [true, false], message: "Should either be male or female"
  #validation

  
  # callbacks
  # before_validation :convert_lower
#  before_validation :convert_country_code
  # callbacks

  #relation
  belongs_to :profile
  #relation

  #ransack
  # delegate :id, to: :interest_areas, prefix: true

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(contacts.created_at)")
  end

  ransacker :first_name do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('first_name'))
  end

  ransacker :last_name do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('last_name'))
  end

  scope :matches_all_attributes, -> *attribute_ids { where(matches_all_attributes_arel(attribute_ids)) }

  def self.matches_all_attributes_arel(attribute_ids)
    contacts = Arel::Table.new(:contacts)
    attributes = Arel::Table.new(:attributes)
    contacts_attributes = Arel::Table.new(:contacts_attributes)

    contacts[:id].in(
      contacts.project(contacts[:id])
        .join(contacts_attributes).on(contacts[:id].eq(contacts_attributes[:contact_id]))
        .join(attributes).on(contacts_attributes[:attribute_id].eq(attributes[:id]))
        .where(attributes[:id].in(attribute_ids))
    )
  end

  def self.ransackable_scopes(auth_object = nil)
    if auth_object
      super + %w(matches_all_attributes)
    else
      super
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    if auth_object == "newsletter"
      %w(gender country city interest_areas_id)
    elsif auth_object == "own"
      %w(first_name last_name email created_at status)
    else
      %w(first_name last_name email created_at status)
    end
  end

  
 

  # class methods
  class << self

    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Contact.find(ids).each do |contact|
        if action == 'delete'
          contact.destroy
        else
          status = action == 'enable' ? 1 : 0
          contact.update(:status => status )
        end
      end
    end

    def accessible_attributes
      ["first_name", "last_name", "email", "company_id", "gender", "country", "city", "profile_ids", "interest_areas_id"]
    end
    
    def import_records(file, profile_id = nil)
      profile = Profile.find(profile_id)
      CSV.foreach(file.path, headers: true) do |row|  
        (profile ? profile.contacts : Contact).create(row.to_hash) 
      end      
    end
    
    #Company Export contact 
    def to_csv(options = {})
      column_names = ["first_name", "last_name", "email","country","city","gender","status","created_at" ] 
      column_names_csv = ["first_name", "last_name", "email","country","city","gender","status","Date" ] 
      CSV.generate(options) do |csv|
        csv << column_names_csv
        all.each do |contact|
          country = contact.try(:country_name)
          contact = contact.attributes.values_at(*column_names)
          contact[3] = country
          contact[5] = contact[5].present? ? 'Male' : 'Female' # override product status to enabel desable
          contact[6] = contact[6].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
          contact[7] = contact[7].to_datetime.strftime("%d/%m/%y, %I:%M %p")
          csv << contact
        end
      end
    end

    #Admin Export
    def to_admin_csv(options = {})
      column_names = ["company_id", "first_name", "last_name", "email","country","city","gender", "status","created_at"] 
      column_names_csv = ["company", "first_name", "last_name", "email","country","city","gender", "status","Date"] 
      CSV.generate(options) do |csv|
        csv << column_names_csv
        all.each do |contact|
          country = contact.try(:country_name)
          contact = contact.attributes.values_at(*column_names)
          contact[0] = Company.find(contact[0]).try(:name) if contact[0].present?
          contact[4] = country
          contact[6] = contact[6].present? ? 'Male' : 'Female'
          contact[7] = contact[7].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
          contact[8] = contact[8].to_datetime.strftime("%d/%m/%y, %I:%M %p")
          csv << contact
        end
      end
    end

  end
  # class methods

  def name
   # "#{first_name} #{last_name}"
    ""
  end 
end
