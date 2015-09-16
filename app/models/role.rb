# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ActiveRecord::Base
  # Soft Delete
  acts_as_paranoid
 # has_and_belongs_to_many :functions

  has_many :accesses, dependent: :destroy
  has_many :functions, through: :accesses
  has_many :users

#  after_save :update_agent_supervisor
  validates :name, presence: true, uniqueness: true, format: { with: /\A[[:word:][:blank:]]+\z/}

  default_scope order(:name)
  scope :all_no_admin, where("id != ?", ADMIN)
#  scope :only_agents, where("is_agent = ?", true)

#  before_destroy :check_admin

#  prevent_destroy_if_any :users

 

  def name=(value)
    write_attribute(:name, value.downcase)
  end

  # def update_agent_supervisor
  #   unless user_ids.blank?
  #     User.update_all({is_agent: is_agent, is_supervisor: is_supervisor}, id: user_ids)
  #     if is_agent #create relation in Agent
  #       user_ids.each do |id|
  #         user = User.find(id)
  #         user.build_agent.save
  #       end
  #     end
  #   end
  # end

  private
    def check_admin
      if self.id == ADMIN
        errors.add :base, "no puedes eliminar el rol admin"
        return false
      end
    end
end
