# == Schema Information
#
# Table name: attributes
#
#  id          :integer          not null, primary key
#  company_id  :integer
#  name        :string
#  description :text
#  status      :boolean
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Attribute < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :company
end
