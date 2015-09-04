class Newsletter < ActiveRecord::Base
  belongs_to :campeign
  belongs_to :template
end
