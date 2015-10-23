# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  company_id :integer
#  first_name :string
#  last_name  :string
#  email      :string
#  status     :boolean          default(TRUE)
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string
#  country    :string
#  gender     :string
#
# Indexes
#
#  index_contacts_on_company_id  (company_id)
#

class Contact < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant
  GENDERS = ['male', 'female']
  #scope
  default_scope {order('id ASC')}
  scope :active, -> { where(status: 'true') }
  #scope

  #validation
  validates :first_name, presence: true, length: { in: 2..50}
  validates_presence_of :email
  validates_uniqueness_to_tenant :email
  validates_format_of :email, :with => Devise.email_regexp
  validates_inclusion_of :status, in: [true, false]
  validates_inclusion_of :gender, in: GENDERS
  #validation

  
  #relation
  has_and_belongs_to_many :profiles
  has_and_belongs_to_many :interest_areas, class_name: "Attribute", join_table: "contacts_attributes"
  #relation

  # callbacks
  before_validation :convert_lower
  before_validation :convert_country_code
  # callbacks

  #ransack
  # delegate :id, to: :interest_areas, prefix: true

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(contacts.created_at)")
  end

  def self.ransackable_attributes(auth_object = nil)
    %w(id first_name last_name email created_at)
  end

  def country_name
    country_name = ISO3166::Country[country]
    country_name.name
  end  
  #ransack

  def convert_lower
    self.gender.try(:downcase!) 
  end

  def convert_country_code
    self.country = ISO3166::Country.find_by_name(country).try(:first) unless ISO3166::Country[country]
  end
  # class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Contact.find(ids).each do |contact|
        if action == 'delete'
          contact.destroy!
        else
          status = action == 'enable' ? 1 : 0
          contact.update(:status => status )
        end
      end
    end

    def accessible_attributes
      ["first_name", "last_name", "email", "company_id", "gender", "country", "city"]
    end
    
    def import_records(file, profile_id = nil)
      profile = Profile.find(profile_id)
      CSV.foreach(file.path, headers: true) do |row|  
        (profile ? profile.contacts : Contact).create(row.to_hash) 
      end      
    end
    
    #Company Export contact 
    def to_csv(options = {})
      column_names = ["first_name", "last_name", "email", "status","created_at"] 
      CSV.generate(options) do |csv|
        csv << column_names
        all.each do |contact|
          contact = contact.attributes.values_at(*column_names)
          contact[3] = contact[3].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
          contact[4] = contact[4].to_datetime
          csv << contact
        end
      end
    end

    #Admin Export
    def to_admin_csv(options = {})
      column_names = ["company_id", "first_name", "last_name", "email", "status","created_at"] 
      column_names_csv = ["company", "first_name", "last_name", "email", "status","created_at"] 
      CSV.generate(options) do |csv|
        csv << column_names_csv
        all.each do |contact|
          contact = contact.attributes.values_at(*column_names)
          contact[0] = Company.find(contact[0]).try(:name) if contact[0].present?
          contact[4] = contact[4].present? ? 'enable' : 'desable' # override product status to enabel desable
          contact[5] = contact[5].to_datetime
          csv << contact
        end
      end
    end

  end
  # class methods

  def name
    "#{first_name} #{last_name}"
  end 

end
