# == Schema Information
#
# Table name: templates
#
#  id         :integer          not null, primary key
#  name       :string
#  content    :text
#  status     :boolean
#  created_by :integer
#  updated_by :integer
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#
# Indexes
#
#  index_templates_on_company_id  (company_id)
#

class Template < ActiveRecord::Base
  
  acts_as_paranoid # Soft Delete

  acts_as_tenant(:company) #multitenant#multitenant

  #scope
  default_scope {order('id DESC')}
  scope :active, -> { where(status: 'true') }
  #scope

  # validation
  validates_presence_of :name, :content
  validates_uniqueness_to_tenant :name
  validates_inclusion_of :status, in: [true, false]
  # validation

  #association
  belongs_to :user
  #association

  # class methods
  class << self
    def edit_all(ids, action)
      action = action.strip.downcase
      ids.reject!(&:empty?)
      Template.find(ids).each do |template|
        if action == 'delete'
          template.destroy
        else
          status = action == 'enable' ? 1 : 0
          template.update(:status => status )
        end
      end
    end
  end
  # class methods
end
