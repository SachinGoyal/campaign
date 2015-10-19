class HomeController < ApplicationController

  layout 'dashboard' # set custom layout 

  #filter
  before_action :authenticate_user!
  before_action :check_subdomain
  #filter
  
  def index
  
  end

  def check_subdomain
    if !current_user.is_admin?
      if request.subdomain != current_user.company.subdomain
        redirect_to signout_path ,alert: "You are not authorized to access that subdomain."
      end
    end
  end  

end
