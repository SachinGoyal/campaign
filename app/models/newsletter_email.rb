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
#  sent          :boolean          default(FALSE)
#

class NewsletterEmail < ActiveRecord::Base

	validate :cs_emails

	before_save :populate_profile_emails
	before_save :remove_duplicate_emails_and_strip
	# after_update :update_list
	
	belongs_to :profile
	belongs_to :newsletter, inverse_of: :newsletter_emails

	scope :unsent, -> { where(sent: 'false') }
	scope :sent, -> { where(sent: 'true') }

	## if custom emails changed, change in mailchimp
	def update_list
		if emails_changed? and from_contacts
			emails_was_arr = emails_was.split(",")
			emails_arr = emails.split(",")
			deleted_emails = emails_was_arr.diff emails_arr
			added_emails = emails_arr.diff - emails_was_arr
			
			deleted_emails.each do |email|
				newsletter.email_service(delete_member_from_list(email))
			end

			added_emails.each do |email|
				newsletter.email_service(add_member_to_list(email))
			end
		end
	end

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

	def add_contact(email)
	  emails_arr = self.emails.split(",")
      emails_arr << email
      emails_arr.uniq!
      self.update_attributes(emails: emails_arr.join(","))              
	end

	def delete_email(email)
	  emails_arr = emails.split(",")
      emails_arr.delete(email)
      emails_arr.uniq!
      self.emails = emails_arr.join(',')
      save!
	end
end
