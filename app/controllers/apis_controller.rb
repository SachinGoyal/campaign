class ApisController < ApplicationController	
	  before_action :authenticate_user!

	def index
		@relations = params[:model].constantize.select('id, name').order('name')
    	respond_to do |format|
      		format.json { 
      			# response.headers['X-CSRF-Token'] = "#{form_authenticity_token}"
        		# response.headers['X-CSRF-Param'] = "#{request_forgery_protection_token}"
      			render json: @relations 
      		}
    	end
	end
end
