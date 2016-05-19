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
  #store_accessor :extra_fields
  
  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  #validation
  validates_presence_of :email, length: { in: 3..255}
  validates_presence_of :profile_id, length: { in: 3..255}
  # validates_presence_of :profile_ids, message: 'Please select atleast one'
  validates_uniqueness_to_tenant :email, scope: :deleted_at
  validates_format_of :email, :with => Devise.email_regexp
  validates_inclusion_of :status, in: [true, false]
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
      newsletter_email.newsletter.email_service.add_member_to_list(self.email) if newsletter_email.newsletter.email_service.present?
    end
  end
  
  def remove_from_list
    newsletter_emails = NewsletterEmail.unsent.where('emails LIKE ?', "%#{self.email_was}%")
    newsletter_emails.select("DISTINCT(newsletter_id)").each do |newsletter_email|
      newsletter_email.newsletter.email_service.delete_member_from_list(self.email_was)
    end
    
    newsletter_emails.each do |newsletter_email|
      newsletter_email.delete_email(self.email_was)
    end    
  end


  ransacker :created_at do
    Arel.sql("date(contacts.created_at)")
  end
  
  ransacker :first_name do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('first_name'))
  end

  ransacker :firstname do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('firstname'))
  end

  ransacker :lastname do |parent|  
    Arel::Nodes::InfixOperation.new('->', parent.table[:extra_fields], Arel::Nodes.build_quoted('lastname'))
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
      %w(gender country city profile_id email)
    elsif auth_object == "own"
      %w(first_name last_name email firstname lastname created_at status profile_id)
    else
      %w(first_name last_name email firstname lastname created_at status profile_id)
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
      ["first_name", "last_name", "email", "company_id", "gender", "country", "city", "profile_ids", "interest_areas_id","created_at"]
    end
    
    def import_records(file, profile_id = nil)
      profile = Profile.find(profile_id)
      CSV.foreach(file.path, headers: true) do |row|  
        (profile ? profile.contacts : Contact).create(row.to_hash) 
      end      
    end
    
    #Company Export contact 
    def to_csv(options = {})
      profile = Profile.find(options[:profile_id])
      extra_fields = profile.extra_fields.map(&:field_name)
      column_names = ["email","status"] 
      if extra_fields.present?
        column_names_csv = ["email", "status"] + extra_fields + ["Date"] 
      else
        column_names_csv = ["email", "status"] + ["Date"] 
      end
      CSV.generate(col_sep: "\t") do |csv|
        csv << column_names_csv
        profile.contacts.each do |contact|
          date = contact.created_at
          contacts_hash = contact.attributes.values_at(*column_names)
          contacts_hash[1] = contacts_hash[1].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
          extra_fields.each do |extra|
            contacts_hash << (contact.extra_fields && contact.extra_fields[extra]) || "-"
          end
          contacts_hash << date.to_datetime.strftime("%d/%m/%y %I:%M %p")
          csv << contacts_hash
        end
      end
    end

    #Admin Export
    def to_admin_csv(options = {})
      profile = Profile.find(options[:profile_id])
      if profile.contacts.any? 
       # extra_fields = profile.contacts.last.extra_fields.keys
        extra_fields = profile.contacts.last.try(:extra_fields).try(:keys)
        column_names = ["company_id", "email","status"] 
        if extra_fields.present?
          column_names_csv = ["Company", "email", "status"] + extra_fields + ["Date"] 
        else
          column_names_csv = ["Company", "email", "status"] + ["Date"] 
        end

        CSV.generate() do |csv|
          csv << column_names_csv
          profile.contacts.each do |contact|
            date = contact.created_at
            value = contact.extra_fields.try(:values)
            contact = contact.attributes.values_at(*column_names)
            contact[0] = Company.find(contact[0]).try(:name) if contact[0].present?
            contact[2] = contact[2].present? ? 'Enabled' : 'Disabled' # override product status to enabel desable
            contact = contact + value if extra_fields.present?
            contact =  contact + [date.to_datetime.strftime("%d/%m/%y, %I:%M %p")]
            csv << contact
          end
        end
      end
    end
  end
  # class methods

  def name
    if extra_fields
      "#{extra_fields["firstname"] || extra_fields["first_name"]} #{extra_fields["lastname"] || extra_fields["last_name"]}"
    end 
  end 
end
