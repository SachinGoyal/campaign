class ApisController < ApplicationController	
	  before_action :authenticate_user!

	def index
		@relations = params[:model].constantize.select('id, name').order('name')
    	respond_to do |format|
      		format.json { 
      			render json: @relations 
      		}
    	end
	end
end
