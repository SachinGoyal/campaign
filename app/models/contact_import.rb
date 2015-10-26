require 'csv'

class ContactImport
  # switch to ActiveModel::Model in Rails 4
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :file, :profile_id
  validates :file, presence: true#, :format => { :with => /\A.+\.(csv)\z/ , message: "Upload only csv files" }
  validates :profile_id, presence: true

  def initialize(attributes = {})
    attributes.each { |name, value| send("#{name}=", value) }
  end

  def persisted?
    false
  end

  def save
    if valid?
      if imported_contacts.map(&:valid?).all?
        
        imported_contacts.each do |c|
          ac = c.save
        end
        # (Profile.find(profile_id.to_i).contacts << imported_contacts) if profile_id
        true
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
      contact.attributes = row.to_hash.slice(*Contact.accessible_attributes)
      contact
    end
  end

  def open_spreadsheet
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
