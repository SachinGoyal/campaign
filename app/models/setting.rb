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

class Setting < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :user
end
