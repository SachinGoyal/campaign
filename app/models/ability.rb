class Ability
  include CanCan::Ability

  def initialize(user)
   # user ||= User.new # guest user (not logged in)
  
    alias_action :search, to: :read
    alias_action :edit_all, to: :update
    alias_action :delete, to: :destroy
    alias_action :send_now, to: :create
    
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
