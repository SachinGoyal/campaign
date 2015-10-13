class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
  
    # alias_action :cancel, :start_cancel, to: :cancel_process
    # alias_action :form_disapproved_changes, :approved_changes, :disapproved_changes,  to: :aproved_changes_contract
    if user.is_admin?
      can :manage, :all     
    elsif user.is_companyadmin?
      can :manage, Campaign
      can :manage, Newsletter
      can :manage, Template
      can :manage, Profile
      can :manage, Contact
      can :manage, Role
      can :manage, User
    else   
      user.role.functions.group_by(&:controller).each do |controller, functions|
        functions.each do |function|
          can [function.action.to_sym], function.controller.camelcase.constantize
        end
      end
    end
  end


  def permissions_dependients controller, action
    case controller
      when 'client'
        case action
          when 'read', 'own_clients_read'
            can [:client_relation_options, :advanced_search, :own_advanced_search, :send_mail, ], Client
            # can [:recent], Budget
          when 'update', 'create'
            can [:find_family, :save_family, :remove_family, :actualize], Client
          when 'destroy'
            can [:action_multiple], Client
          when 'new_import'
            can [:change_sheet, :save_import, :list_import, :delete_import, :download_export, :download_export_advanced], Client
          when 'assigned_units_or_clients'
            can [:edit, :update, :action_multiple, :multiple], :assign
            # can [:action_multiple, :assigned_multiple], Client
            can [:assigned, :assigned_update, :action_multiple, :assigned_multiple], Unit
          when 'assigned_sellers_to_client'
            can [:edit, :update], :assign
            can [:action_multiple, :assigned_multiple], Client
        end
      when 'user'
        case action
        when 'read'
          can [:advanced_search], User
        when 'destroy'
          can [:delete_all], User
        when 'create'
          cannot [:create], User do |user_item|
            account = Account.where(name: Setting.first.subdomain).first
            (User.list_users_active.count - 1) >= account.limit_user_active
          end
        end
      when 'project'
        case action
        when "read"
          can [:independent_units, :advanced_search, :index, :show, :map, :map_independent], Project
          can [:show], MetrajeList
          can [:show], PriceList
          can [:recent, :create], Budget
        when "my_projects"
          can [:index, :show, :map], Project
          can [:recent, :create], Budget
        when "update"
          can [:assigned_supervisors, :assigned, :assigned_multiple], Project
        when "destroy"
          can [:action_multiple], Project
        when "new_import"
          can [:list_import, :delete_import, :change_sheet, :save_import], Project
        end
      when 'unit'
        case action
        when "read"
          can [:advanced_search, :client_relations], Unit
        when "create"
          can [:list_blocks], Unit
        when "update"
          can [:change_state, :copy_finishes, :copy_complement, :list_blocks], Unit
        when 'destroy'
          can [:action_multiple], Unit
        when "new_import"
          can [:change_sheet, :list_blocks_import, :list_import, :save_import, :confirm_import, :delete_import], Unit
        when "assigned_sellers_to_unit"
          can [:assigned, :assigned_update, :assigned_multiple, :action_multiple], Unit
        end
      when 'block'
        case action
        when 'read'
          can [:independent_units, :map], Block
        end
      when 'process_unit'
        case action
        when 'separation_process', 'sale_process', 'independization_process'
          can [:create, :select_process_flow], ProcessUnit
        when 'read'
          can [:read, :request_schedule], Payment
        end
      when 'complement'
        case action
        when 'manage'
          can :manage, ComplementCategory
        end
      when 'handing'
        case action
        when 'read'
          can [:sales, :delivery, :associated_files, :request_approved_customization, :update], Handing
        end
      when 'contact'
        case action
        when 'read'
          can [:score_partner, :score_attentions], Contact
        end
      when 'requirement'
        case action
        when 'create_update'
          can [:duplicate, :uploader, :destroy_file], Requirement
        when 'read'
          can [:filter, :warranty], Requirement
        when "new_export"
          can [:download], Requirement
        when 'close'
          can [:form_close], Requirement
        end
      when 'workflow'
        case action
        when 'read'
          can [:tbl_complete, :create, :done], Workflow
        end
      when 'payment'
        case action
        when "edit_payment_at"
          can [:edit_payment_at, :save_payment_at], Payment
        when "edit_estimated_at"
          can [:edit_estimated_at, :save_estimated_at], Payment
        end
    end
  end
end
