# == Schema Information
#
# Table name: extra_fields
#
#  id         :integer          not null, primary key
#  field_name :string
#  field_type :string
#  profile_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExtraField < ActiveRecord::Base
  belongs_to :profile
end
