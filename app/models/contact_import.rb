require 'csv'

class ContactImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  FILE_TYPES = ['text/csv', 'application/csv', 
    'text/comma-separated-values','attachment/csv', "application/vnd.ms-excel", "application/octet-stream"]
  attr_accessor :file, :profile_id
  validates :file, presence: true#, :format => { :with => /\A.+\.(csv)\z/ , message: "Upload only csv files" }
  # validates_format_of :file, :with => %r{\.csv\z}i, :message => "file must be in .csv format"
  # validate :check_file_ext
  validates :profile_id, presence: true

  def check_file_ext
    begin
      if file and !(FILE_TYPES.include?(file.content_type))
        errors[:file] = "should be csv"
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
    if valid?
      if imported_contacts.map(&:valid?).all?
        successfull_records = []
        profile = Profile.find(profile_id.to_i)
        imported_contacts.each_with_index.each do |contact, index|
          if profile.contacts.create(contact.attributes)
            successfull_records << contact
          else
            contact.errors.full_messages.each do |message|
              errors.add :base, "Row #{index+2}: #{message}"
            end
          end
        end        
        
        imported_contacts == successfull_records
        
      else
        imported_contacts.each_with_index do |contact, index|
          contact.errors.full_messages.each do |message|
            errors.add :base, "Row #{index+2}: #{message}"
          end
        end
        false
      end
    else
      false
    end
  end

  def imported_contacts
    @imported_contacts ||= load_imported_contacts
  end

  def load_imported_contacts
    spreadsheet = open_spreadsheet
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).map do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      contact = Contact.find_by_id(row["id"]) || Contact.new
      h = row.to_hash.slice(*Contact.accessible_attributes)
      if h.has_key?("gender")
        if h["gender"] == "male" or h["gender"] == "Male"
          h["gender"] = true
        elsif h["gender"] == "female" or h["gender"] == "Female"
          h["gender"] = false
        end
      end
      contact.attributes = h
      contact
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
