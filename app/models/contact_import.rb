require 'csv'

class ContactImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  FILE_TYPES = ['text/csv', 'application/csv', 
    'text/comma-separated-values','attachment/csv', "application/vnd.ms-excel", "application/octet-stream",
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "application/kset", "application/vnd.xls"]
  attr_accessor :file, :profile_id, :action, :way, :row_count
  validates :file, presence: true#, :format => { :with => /\A.+\.(csv)\z/ , message: "Upload only csv files" }
  # validates_format_of :file, :with => %r{\.csv\z}i, :message => "file must be in .csv format"
  validate :check_file_ext
  validates :profile_id, presence: true
  validates :action, presence: true
  validate :check_way

  def check_file_ext
    begin
      if file and !(FILE_TYPES.include?(file.content_type))
        errors[:file] = I18n.t("frontend.shared.csv")
        false
      end
    rescue   
      errors[:file] = "Something was wrong with file"
      false
    end  
  end

  def check_way
    if action == "Import" and way.blank?
      errors[:way] = I18n.t("frontend.import.select_way")
      return false      
    end
  end
  
  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    successfull_records = []
    begin      
      if valid?
        if action.blank?
          errors[:action] = I18n.t("frontend.import.select_action")
          return false      
        end
        spreadsheet = open_spreadsheet
        if !(spreadsheet.last_row) 
          errors[:base] = " Valid Format (.xls / .xlsx) but complete blank file." 
          return false
        elsif !(spreadsheet.last_row and spreadsheet.last_row > 2) 
          errors[:base] = "Valid Format (.xls / .xlsx) but Only header is present and no data." 
          return false        
        end
      else
        false
      end  

      case self.action
        when "Import"
            profile = Profile.find(profile_id.to_i)
            contacts = imported_contacts(profile).compact
            if imported_contacts(profile).compact.any? && imported_contacts(profile).compact.map(&:valid?).all?
              imported_contacts(profile).compact.each_with_index.each do |contact, index|
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

              if imported_contacts(profile).compact.any?
                imported_contacts(profile).each_with_index do |contact, index|
                  contact.errors.full_messages.each do |message|
                    errors.add :base, "Row #{index+2}: #{message}"
                  end
                end
              end
              false
            end
          
        when "Unsubscribe"
            profile = Profile.find(profile_id.to_i)
            emails = profile.contacts.map(&:email)
            header = spreadsheet.row(1)
            if emails.empty?
              errors.add :base, "Selected Profile is empty"
            else            
              (2..spreadsheet.last_row).to_a.map do |index|
                row = Hash[[header, spreadsheet.row(index)].transpose]
                if emails.include?(row["email"])
                  Contact.find_by_email(row["email"]).update_attributes(:status => false)
                else
                  errors.add :base, "Row #{index}: #{row['email']} not found"
                end
              end
            end
          
      end
    rescue
      false
    end
    if errors.any?
      if successfull_records.present?
        successfull_records.each do |record|
          errors.add :base, "#{record.email} added successfully" 
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
          contact = profile.contacts.find_by_email(row["email"])
          errors.add :base, "#{row['email']} already exists" if contact
          contact = contact.present? ? nil : Contact.new
        when "Replace"
          contact = profile.contacts.find_by_email(row["email"])
          unless contact.present?
            errors.add :base, "Row #{i}: Email  #{row["email"]} not exist "
          end
        when "Add/Update"
          contact = profile.contacts.find_by_email(row["email"]) || Contact.new
      end
      if contact.present? 
        h = row.to_hash.slice(*Contact.accessible_attributes)
        hash = {}
        attributes.each do |field|
          hash[field] = row[field]
        end
        contact.extra_fields = hash
        contact.email = row["email"]
        (contact.status = row["status"] == 'Enabled' ? true : false) if row["status"].present?
        contact.profile_id = profile_id
        contact
      else
        
      end

    end
  end

  def open_spreadsheet
    begin
      case File.extname(file.original_filename)
        when ".csv" then Roo::CSV.new(file.path)
        when ".xls" then Roo::Excel.new(file.path)
        when ".xlsx" then Roo::Excelx.new(file.path)
      else 
          raise "Unknown file type: #{file.original_filename}"
      end
    rescue
      errors.add :base, "#{file.original_filename} Incompatible File"
    end
  end
end
