class NewsletterEmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def unsubscribe
    body = JSON.parse(request.body)
    if body[:type] == "unsubscribe"
        contact = Contact.where(email: body["data"]["email"]).first        
        contact.destroy     
    end    
    render :nothing => true
  end


  # def unsubscribe
  #   body = JSON.parse(request.body)
  #   if body[:type] == "unsubscribe"
  #       contact = Contact.where(email: body["data"]["email"]).first
  #       profiles = []
  #       EmailService.where(list_id: body["data"]["list_id"]).each do |email_service|
  #       	ne = email_service.newsletter.newsletter_emails
  #       	profiles << ne.collect(&:profile)
  #       	# ne.unsent.each {|n|	n.delete_email(request["email"]) }
  #       end
  #       profiles.flatten!.uniq!
  #       Contact.where(:profile_id => profiles.map(&:id)).each do |contact|
  #           contact.destroy    	
  #       end
  #   end    
  #   render :nothing => true
  # end
end
