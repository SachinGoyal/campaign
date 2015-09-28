# == Schema Information
#
# Table name: settings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  site_title           :string
#  admin_email          :string
#  admin_footer_content :string
#  deleted_at           :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_settings_on_user_id  (user_id)
#

class Setting < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete
  
  belongs_to :user
end
