# == Schema Information
#
# Table name: extra_fields
#
#  id         :integer          not null, primary key
#  field_name :string
#  profile_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExtraField < ActiveRecord::Base
  validates_uniqueness_of :field_name, :scope => :profile_id
  belongs_to :profile

  before_validation :remove_trailing_space

  def remove_trailing_space
  	self.field_name.strip!
  end
end
