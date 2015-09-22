class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  

  protect_from_forgery with: :exception
  # before_action :authenticate_tenant!   # authenticate user and sets up tenant

  # rescue_from ::Milia::Control::MaxTenantExceeded, :with => :max_tenants
  # rescue_from ::Milia::Control::InvalidTenantAccess, :with => :invalid_tenant
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end

  def current_company # get company of current user
    current_user.company
  end

end
