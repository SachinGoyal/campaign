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
	belongs_to :newsletter
end
