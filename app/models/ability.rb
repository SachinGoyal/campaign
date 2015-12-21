class Ability
  include CanCan::Ability

  def initialize(user)
   # user ||= User.new # guest user (not logged in)
  
    alias_action :search, to: :read
    alias_action :copy, to: :create
    alias_action :edit_all, to: :update
    alias_action :delete, to: :destroy
    alias_action :send_now, to: :create
    alias_action :preview, to: :create
    alias_action :stats, to: :read
    alias_action :reports, to: :read
    alias_action :reports, to: :read
    alias_action :reports, to: :read
    alias_action :reports, to: :read
    alias_action :select_newsletter, to: :read
    alias_action :sample_fields, to: :read
    alias_action :dynamic_field, to: :read
    alias_action :import, to: :read
    alias_action :preview, to: :read
    alias_action :select_newsletter, to: :read
    alias_action :select_newsletter, to: :read
    
    if user.is_admin?
      can :manage, :all     
    else   
      can :manage, Function
      can :manage, Access
      user.role.functions.group_by(&:controller).each do |controller, functions|
        functions.each do |function|
          can [function.action.to_sym], function.controller.camelcase.constantize
        end
      end
    end
  end
end
