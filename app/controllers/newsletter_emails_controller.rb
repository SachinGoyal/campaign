class NewsletterEmailsController < ApplicationController
  def unsubscribe
    request = parse_request
    contact = Contact.where(email: request["email"]).first
    profiles = []
    EmailService.where(list_id: request["list_id"]).each do |email_service|
    	ne = email_service.newsletter.newsletter_emails
    	profiles << ne.collect(&:profile)
    	ne.unsent.each {|n|	n.delete_contact(request["email"]) }
    end
    profiles.flatten!.uniq!
    profiles.each do |profile|
    	
    end
    render :nothing => true
  end
end
