class NewsletterEmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def unsubscribe
    request = parse_request
    contact = Contact.where(email: request["email"]).first
    profiles = []
    EmailService.where(list_id: request["list_id"]).each do |email_service|
    	ne = email_service.newsletter.newsletter_emails
    	profiles << ne.collect(&:profile)
    	# ne.unsent.each {|n|	n.delete_email(request["email"]) }
    end
    profiles.flatten!.uniq!
    Contact.where(:profile_id => profiles.map(&:id)).each do |contact|
        contact.destroy    	
    end
    render :nothing => true
  end
end
