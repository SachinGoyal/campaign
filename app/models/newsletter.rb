class Newsletter < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  belongs_to :campeign
  belongs_to :template
end
