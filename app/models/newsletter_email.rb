# == Schema Information
#
# Table name: newsletter_emails
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  profile_id    :integer
#  emails        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sample        :boolean
#  from_contacts :boolean
#  sent          :boolean          default(TRUE)
#

class NewsletterEmail < ActiveRecord::Base

	validate :cs_emails

	before_save :populate_profile_emails
	before_save :remove_duplicate_emails_and_strip

	belongs_to :profile
	belongs_to :newsletter, inverse_of: :newsletter_emails

	scope :unsent, -> { where(sent: 'false') }
	scope :sent, -> { where(sent: 'true') }

	def cs_emails
	  invalid_emails = []
	  if emails
		emails.delete(' ').split(",").each do |email|
		  invalid_emails << email if (email =~ Devise.email_regexp).nil?
		end
		unless invalid_emails.empty?
		  errors[:emails] << invalid_emails.join(", ") + " are invalid"
		end
	  end		
	end

	def populate_profile_emails		
	  self.emails = profile.contacts.active.map(&:email).join(",") if profile
	end

	def remove_duplicate_emails_and_strip
	  self.emails = self.emails.split(",").map(&:strip).uniq.join(",")
	end

	def mark_sent
	  update_attributes(:sent => true)
	end

	def delete_email
	end

	def add_contact(email)
	  emails_arr = self.emails.split(",")
      emails_arr << email
      self.update_attributes(emails: emails_arr.join(","))              
	end

	def delete_contact(email)
	  emails_arr = self.emails.split(",")
      emails_arr.delete(email)
      self.update_attributes(emails: emails_arr.join(","))
	end
end
