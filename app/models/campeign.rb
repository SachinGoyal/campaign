class Campeign < ActiveRecord::Base
  # relation
  belongs_to :user
  # relation
  
  #delegate
  delegate :username, to: :user, prefix: true
  #delegate

end
