# == Schema Information
#
# Table name: email_services
#
#  id                       :integer          not null, primary key
#  newsletter_id            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  list_id                  :string
#  campaign_id              :string
#  company_id               :integer
#  opens_total              :integer
#  unique_opens             :integer
#  clicks_total             :integer
#  unique_clicks            :integer
#  unique_subscriber_clicks :integer
#  hard_bounces             :integer
#  soft_bounces             :integer
#  unsubscribed             :integer
#  forwards_count           :integer
#  forwards_opens           :integer
#  emails_sent              :integer
#  abuse_reports            :integer
#  send_at                  :datetime
#  template_id              :integer
#  scheduled_at             :datetime
#  user_id                  :integer
#
# Indexes
#
#  index_email_services_on_newsletter_id  (newsletter_id)
#

class EmailService < ActiveRecord::Base
  
  acts_as_tenant(:company) #multitenant
  belongs_to :newsletter
  belongs_to :creator, class_name: "User", foreign_key: :user_id

  delegate :name, :subject, :from_address, :from_name, :to => :newsletter

  def create_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns.create({
                       :body => { 
                          :type => "regular", 
  									      :recipients =>  {:list_id => list_id}, 
  									       :settings => {
                               :subject_line  => subject,				   	
  									   				 :title         => subject,
  									   				 :reply_to      => from_address, 
  									   				 :from_name     => from_name,
                               :template_id   => 26205 }
  									   }
  							})
  	
  		self.campaign_id = response["id"]
  		save
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def update_campaign
    gb = gibbon_request
    begin
      response = gb.campaigns(campaign_id).patch({
                       :body => { 
                          :type => "regular", 
                          :recipients =>  {:list_id => list_id}, 
                           :settings => {
                               :subject_line  => subject,           
                               :title         => subject,
                               :reply_to      => from_address, 
                               :from_name     => from_name,
                               :template_id   => 74661 }
                       }
                })
    
      self.campaign_id = response["id"]
      save
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def send_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns(campaign_id).actions.send.create
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def schedule_campaign
    begin
      response = HTTParty.post(V2_URL+"2.0/campaigns/schedule", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :cid => campaign_id, 
                      :schedule_time => newsletter.send_at.strftime("%Y-%m-%d %H:%M:%S")
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' })
      
      update_attributes(:scheduled_at => newsletter.send_at) if response.has_key?("complete") and response["complete"]
    rescue Exception => e
      puts e.message
      ApplicationMailer.mailchimp_error(creator, "#{e.message}").deliver_now
    end
  end

  def delete_campaign
    gb = gibbon_request
    begin
      response = gb.campaigns(campaign_id).delete
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end


  def create_list
  	gb = gibbon_request
  	begin
  		response = gb.lists.create(
                    :body => {
                      :name => name,
  								    :contact => {
                        :company  => company.try(:name) || "Sperant",
  								  		:address1 => "address1",
  								  		:city     => "New Delhi",
  								  		:state    => "Delhi",
  								  		:zip      => "110058",
  								  		:country  => "India"
  								  	},
  								  :permission_reminder => I18n.t('words.permission_reminder'),
  								  :campaign_defaults => {
                      :from_name       => from_name,
  								  	:from_email      => from_address,
  								  	:subject         => subject,
  								  	:language        => I18n.locale.to_s.upcase},
  								  :email_type_option => true,
  								 })

  		self.list_id = response["id"]
  		save
  		self.list_id
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def self.fetch_lists
  	gb = gibbon_request
  	begin
  		response = gb.lists.retrieve
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def fetch_list
    gb = gibbon_request
    begin
      response = gb.lists(list_id).retrieve
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def members_in_list
        gb = gibbon_request
    begin
      response = gb.lists(list_id).members.retrieve
      response["members"]
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end


  def add_member_to_list(email)
  	gb = gibbon_request
  	begin
      gb.lists(list_id).members.create(body: {email_address: email, status: "subscribed"})
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def add_members_to_list(emails)
  	gb = gibbon_request
  	begin
  		email_arr = []
  		emails.each do |email|
  			email_arr << { :method => 'POST', 
  						         :path => "lists/#{list_id}/members", 
  						         :body => "{\"email_address\":\"#{email}\", \"status\":\"subscribed\"}" }
  		end		
  		response = gb.batches.create({:body => {
  										:operations => email_arr  												
  									}})      
  	rescue Gibbon::MailChimpError => e      
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def delete_member_from_list(email)
    gb = gibbon_request
    begin
      response = gb.lists(list_id).members(Digest::MD5.hexdigest(email)).delete
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def fetch_clients
    gb = gibbon_request
    begin
      response = gb.lists(list_id).clients.retrieve
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def get_stats
    gb = gibbon_request
    begin
      response = gb.reports(campaign_id).retrieve
      self.emails_sent = response["emails_sent"]
      self.abuse_reports = response["abuse_reports"]
      self.unsubscribed = response["unsubscribed"]
      if response.has_key?("bounces")
        self.hard_bounces = response["bounces"]["hard_bounces"]
        self.soft_bounces = response["bounces"]["soft_bounces"]
      end  
      if response.has_key?("forwards")
        self.forwards_opens = response["forwards"]["forwards_opens"]
        self.forwards_count = response["forwards"]["forwards_count"]
      end
      if response.has_key?("opens")
        self.opens_total = response["opens"]["opens_total"]
        self.unique_opens = response["opens"]["unique_opens"]        
      end
      if response.has_key?("clicks")
        self.clicks_total = response["clicks"]["clicks_total"]
        self.unique_clicks = response["clicks"]["unique_clicks"]        
      end
      save

    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def update_stats
    begin
      
    rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def create_template
    begin
      response = HTTParty.post(V2_URL+"2.0/templates/add", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :name => name, 
                      :html => newsletter.template.content
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )
      self.template_id = response["template_id"]
      save
    rescue Exception => e
      puts e.message
      ApplicationMailer.mailchimp_error(creator, "#{e.raw_body}").deliver_now
    end
    #  curl -H "Content-Type: application/json" -X POST -d '{"apikey":"fe7ef49e4934c504860020bd65e2fdc3-us12","name":"dummy", "html": "example html"}' https://us12.api.mailchimp.com/2.0/templates/add
  end

  def edit_template
  end
  
  def gibbon_request
  	Gibbon::Request.new(api_key: GIBBON_KEY)
  end
end
