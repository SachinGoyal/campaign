class HomeController < ApplicationController

  layout 'dashboard' # set custom layout 

  #filter
  before_action :authenticate_user!
  #filter
  
  def index
  
  end

end
