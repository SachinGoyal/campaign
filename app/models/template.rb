# == Schema Information
#
# Table name: templates
#
#  id              :integer          not null, primary key
#  name            :string
#  content         :text
#  status          :boolean
#  created_by      :integer
#  updated_by      :integer
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  company_id      :integer
#  template_images :json
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
  validates :name, presence: true, length: { in: 2..250}
  validates :content, presence: true
  validates_uniqueness_to_tenant :name
  validates_inclusion_of :status, in: [true, false]
  # validation

  #callback
  before_destroy :check_newsletter
  before_update :check_newsletter
  #callback

  #association
  has_many :newsletters
  #association

  mount_uploaders :template_image, TemplateImageUploader
  #ransack

  ransacker :created_at do
    Arel::Nodes::SqlLiteral.new("date(templates.created_at)")
  end
  
  def self.ransackable_attributes(auth_object = nil)
    super & %w(name content created_at)
  end

  #ransack

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

  protected

  def check_newsletter
    if newsletters.any?
      errors.add(:base, :associated_newsletter)
      return false
    end
  end
end
