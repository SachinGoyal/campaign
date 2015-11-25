class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  protect_from_forgery with: :exception
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  set_current_tenant_by_subdomain(:company, :subdomain)  
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  layout :layout_by_resource

  def pick_model_from_locale(model_name)
     I18n.backend.send(:translations)[I18n.locale][:activerecord][:models][model_name]
  end

  protected
  
  def layout_by_resource
    if devise_controller? && resource_name == :user && ["sessions", "passwords", "confirmations", 'invitations'].include?(controller_name)
      "application"
    else
      "dashboard"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password, :image) }
  end
end
