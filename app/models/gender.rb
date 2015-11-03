# == Schema Information
#
# Table name: genders
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

 class Gender #< ActiveRecord::Base
# 	VALUES = ['Male', 'Female']

# 	# validations
# 	validates :name, presence: true, uniqueness: true
# 	validates_inclusion_of :name, in: VALUES
	# validations
end
