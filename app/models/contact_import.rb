require 'csv'

class ContactImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  FILE_TYPES = ['text/csv', 'application/csv', 
    'text/comma-separated-values','attachment/csv', "application/vnd.ms-excel", "application/octet-stream"]
  attr_accessor :file, :profile_id, :action, :way
  validates :file, presence: true#, :format => { :with => /\A.+\.(csv)\z/ , message: "Upload only csv files" }
  # validates_format_of :file, :with => %r{\.csv\z}i, :message => "file must be in .csv format"
   # validate :check_file_ext
  validates :profile_id, presence: true
  validates :action, presence: true
#  validates :profile_id, presence: true
  def check_file_ext
    begin
      if file and !(FILE_TYPES.include?(file.content_type))
        errors[:file] = I18n.t("frontend.csv")
        false
      end
    rescue
      true
    end  
  end
  
  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    profile = Profile.find(profile_id.to_i)
    case self.action
      when "Import"
        if valid?
          contacts = imported_contacts(profile).compact
          if contacts.any? && contacts.map(&:valid?).all?
            successfull_records = []
            contacts.each_with_index.each do |contact, index|
              if contact.new_record?
                if profile.contacts.create(contact.attributes)
                  successfull_records << contact
                else
                  contact.errors.full_messages.each do |message|
                    errors.add :base, "Row #{index+2}: #{message}"
                  end
                end
              else
                if contact.save
                  successfull_records << contact
                else
                  contact.errors.full_messages.each do |message|
                    errors.add :base, "Row #{index+2}: #{message}"
                  end
                end
              end
            end
              
            
            imported_contacts(profile) == successfull_records
            
          else
            imported_contacts(profile).each_with_index do |contact, index|
              contact.errors.full_messages.each do |message|
                errors.add :base, "Row #{index+2}: #{message}"
              end
            end
            false
          end
        else
          false
        end
      when "Unsubscribe"
        emails = profile.contacts.map(&:email)
        spreadsheet = open_spreadsheet
        header = spreadsheet.row(1)
        (2..spreadsheet.last_row).to_a.map do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          if emails.include?(row["email"])
            Contact.find_by_email(row["email"]).destroy
          end
        end

    end
  end

  def imported_contacts profile
    @imported_contacts ||= load_imported_contacts(profile)
  end

  def load_imported_contacts profile
    attributes = profile.extra_fields.map(&:field_name)                                                                                                                                                                                                                                                                                   
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).to_a.map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      case self.way

        when "Add"
          contact = Contact.find_by_email(row["email"])
          contact = contact.present? ? nil : Contact.new
        when "Replace"
          contact = Contact.find_by_email(row["email"])
        when "Add/Update"
          contact = Contact.find_by_email(row["email"]) || Contact.new
      end
      if contact.present? 
        h = row.to_hash.slice(*Contact.accessible_attributes)
        hash = {}
        attributes.each do |field|
          hash[field] = row[field]
        end
        contact.extra_fields = hash
        contact.email = row["email"]
        contact.status = row["status"] == 'Enabled' ? true : false 
        contact
      end
    end
  end

  def open_spreadsheet

    case File.extname(file.original_filename)
      when ".csv" then Roo::CSV.new(file.path)
      when ".xls" then Roo::Excel.new(file.path)
      when ".xlsx" then Roo::Excelx.new(file.path)
    else 
        raise "Unknown file type: #{file.original_filename}"
    end
  end
end
