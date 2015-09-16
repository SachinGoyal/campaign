# == Schema Information
#
# Table name: templates
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string
#  content    :text
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_templates_on_user_id  (user_id)
#

class Template < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :user
end
