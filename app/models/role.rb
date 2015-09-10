# == Schema Information
#
# Table name: roles
#
#  id                     :integer          not null, primary key
#  name                   :string(255)      not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#




class Role < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid

end
