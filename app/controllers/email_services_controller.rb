class EmailServicesController < ApplicationController


  def index
  	# @email_service = EmailService.find(params[:id])
  	Newsletter.first.save
  	gb = Gibbon::Request.new(api_key: "fe7ef49e4934c504860020bd65e2fdc3-us12")
  	begin
  		# response = gb.campaigns.create({:body => {:type => "plaintext", 
  		# 							   :recipients =>  {:list_id=>"adacda43cf"}, 
  		# 							   :settings => {:subject_line => @email_service.subject,				   	
  		# 							   				 :title => @email_service.subject
  		# 							   				 :reply_to => @email_service.from_address, 
  		# 							   				 :from_name => "abc",
  		#											 :to_name =>"Programmer"}
  		# 							   }
  		# 					})
  		# campaign_id = response["id"]

  		# send_response = gb.campaigns(campaign_id).actions.send
  		# response = gb.batches.create({:body => {
  		# 								:operations => [
  		# 										{ :method => 'POST', 
  		# 										  :path => 'lists/adacda43cf/members', 
  		# 										  :body => "{\"email_address\":\"email1@domain.tld\", \"status\":\"subscribed\"}" }
  		# 										] 
  		# 							}})
  		# binding.pry

  		campaign_id = "7ec6edb4c9"
  		# response = gb.campaigns(campaign_id).actions.send.create

  	rescue Exception => e
  		# binding.pry
  	end		
  end
end
