# == Schema Information
#
# Table name: email_services
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_email_services_on_newsletter_id  (newsletter_id)
#

class EmailService < ActiveRecord::Base
  belongs_to :newsletter

  delegate :subject, :from_address, :from_name, :to => :newsletter

  def create_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns.create({:body => {:type => "plaintext", 
  									   :recipients =>  {:list_id=>"adacda43cf"}, 
  									   :settings => {:subject_line => @email_service.subject,				   	
  									   				 :title => @email_service.subject
  									   				 :reply_to => @email_service.from_address, 
  									   				 :from_name => "abc",
  													 :to_name =>"Programmer"}
  									   }
  							})
  		campaign_id = response["id"]
  	rescue Exception => e
  	end
  end

  def send_campaign
  	gb = gibbon_request
  	begin
  	rescue Exception => e
  	end
  end

  def create_list
  	gb = gibbon_request
  	begin
  	rescue Exception => e
  	end
  end

  def fetch_lists
  	gb = gibbon_request
  	begin
  	rescue Exception => e
  	end
  end

  def add_member_to_list(list_id)
  	gb = gibbon_request
  	begin
  	rescue Exception => e
  	end
  end

  def add_members_to_list(list_id)
  	gb = gibbon_request
  	begin
  		response = gb.batches.create({:body => {
  										:operations => [
  												{ :method => 'POST', 
  												  :path => 'lists/adacda43cf/members', 
  												  :body => "{\"email_address\":\"email1@domain.tld\", \"status\":\"subscribed\"}" }
  												] 
  									}})
  	rescue Exception => e
  	end
  end

  def get_stats
  end
  
  def gibbon_request
  	Gibbon::Request.new(api_key: "fe7ef49e4934c504860020bd65e2fdc3-us12")
  end
end