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
#

class NewsletterEmail < ActiveRecord::Base
	belongs_to :profile
	belongs_to :newsletter, inverse_of: :newsletter_emails

	validate :cs_emails
	before_save :populate_profile_emails
	before_save :remove_duplicate_emails_and_strip

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
end
