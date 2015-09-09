class Attribute < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :company
end
