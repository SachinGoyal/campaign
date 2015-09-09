class Company < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
end
