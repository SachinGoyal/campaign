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
  after_create :add_to_list
  after_destroy :remove_from_list
  after_update :update_list_for_status
  # callbacks

  #relation
  belongs_to :profile
  #relation

  def update_list_for_status
    if status_changed?
      if status
        add_to_list
      else
        remove_from_list
      end
    end
  end

  def add_to_list    
    newsletter_emails = NewsletterEmail.unsent.where(:profile_id => profile_id)
    newsletter_emails.each do |newsletter_email|
      newsletter_email.add_contact(self.email)
    end
    newsletter_emails.select("DISTINCT(newsletter_id)").each do |newsletter_email|
      newsletter_email.newsletter.email_service.add_member_to_list(self.email)
    end
  end
  
  def remove_from_list
    newsletter_emails = NewsletterEmail.unsent.where('emails LIKE ?', "%#{self.email_was}%")
    newsletter_emails.each do |newsletter_email|
      newsletter_email.delete_email(self.email_was)
    end
    
    newsletter_emails.select("DISTINCT(newsletter_id)").each do |newsletter_email|
      newsletter_email.newsletter.email_service.delete_member_from_list(self.email_was)
    end
  end

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(contacts.created_at)")
  end

  ransacker :first_name do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('first_name'))
  end

  ransacker :last_name do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('last_name'))
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
      %w(gender country city profile_id )
    elsif auth_object == "own"
      %w(first_name last_name email created_at status profile_id)
    else
      %w(first_name last_name email created_at status profile_id)
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
      profile = Profile.find(24)
      extra_fields = profile.contacts.first.extra_fields.keys
      column_names = ["email","status"] 
      column_names_csv = ["Email", "Status"] + extra_fields + ["Date"]
      CSV.generate(options) do |csv|
        csv << column_names_csv
        profile.contacts.each do |contact|
          date = contact.created_at
          value = contact.extra_fields.values
          contact = contact.attributes.values_at(*column_names)
          contact[1] = contact[1].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
          contact = contact + value
          contact =  contact + [date.to_datetime.strftime("%d/%m/%y, %I:%M %p")]
          csv << contact
        end
      end
    end

    #Admin Export
    def to_admin_csv(options = {},profile_id = '')
      profile = Profile.find(24)
      binding.pry
      if profile.contacts.any? 
        extra_fields = profile.contacts.last.extra_fields.keys
        column_names = ["company_id", "email","status"] 
        column_names_csv = ["Company", "email", "status"] + extra_fields + ["Date"]
        CSV.generate(options) do |csv|
          csv << column_names_csv
          profile.contacts.each do |contact|
            date = contact.created_at
            value = contact.extra_fields.values
            contact = contact.attributes.values_at(*column_names)
            contact[0] = Company.find(contact[0]).try(:name) if contact[0].present?
            contact[2] = contact[2].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
            contact = contact + value
            contact =  contact + [date.to_datetime.strftime("%d/%m/%y, %I:%M %p")]
            csv << contact
          end
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
