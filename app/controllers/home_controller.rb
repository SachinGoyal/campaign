class HomeController < ApplicationController
  
  layout 'dashboard' # set custom layout 

  before_action :authenticate_user!
  
  def index
  
  end

end
