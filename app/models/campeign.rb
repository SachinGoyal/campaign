class Campeign < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
  # relation
  belongs_to :user
  # relation
  
  #delegate
  delegate :username, to: :user, prefix: true
  #delegate

end
