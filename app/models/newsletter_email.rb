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

	def cs_emails
		invalid_emails = []
		emails.delete(' ').split(",").each do |email|
			invalid_emails << email if (email =~ Devise.email_regexp).nil?
		end
		unless invalid_emails.empty?
			errors[:emails] << invalid_emails.join(", ") + " are invalid"
		end
	end
end
