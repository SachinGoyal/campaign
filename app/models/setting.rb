class Setting < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :user
end
