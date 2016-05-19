# == Schema Information
#
# Table name: settings
#
#  id                   :integer          not null, primary key
#  site_title           :string
#  free_emails          :string
#  admin_email          :string
#  admin_footer_content :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Setting < ActiveRecord::Base
 #validation
 validates_presence_of :site_title, :free_emails, :admin_email, :admin_footer_content
 #validation

end
