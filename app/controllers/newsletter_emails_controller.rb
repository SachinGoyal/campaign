class NewsletterEmailsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
   def unsubscribe
    body_val = request.body.read

    if params[:type] == "unsubscribe"
        contact = Contact.where(email: params[:data][:email]).first
        contact.update_attributes(:status => false) if contact
    elsif params[:type] == "profile"
      contact = Contact.where(email: params[:data][:email]).first
        contact.update_attributes(:status => true) if contact
    end

   render status: 200, json: {:ok => "ok"}.to_json
 end
end
