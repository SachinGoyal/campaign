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
  include Rails.application.routes.url_helpers  
  acts_as_tenant(:company) #multitenant

  #Callbacks
  before_destroy :delete_dependencies

  #Associations
  belongs_to :newsletter
  belongs_to :creator, class_name: "User", foreign_key: :user_id

  #Delegation
  delegate :name, :subject, :reply_email, :from_name, :to => :newsletter

  #Scope
  scope :unsent, -> { where(:send_at => nil) }

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
  									   				 :reply_to      => reply_email, 
  									   				 :from_name     => from_name
                            }
  									   }
  							})
  	
  		self.campaign_id = response["id"]
  		save
  	rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def update_content
    gb = gibbon_request
    begin
      body = { template: {
                  id: DEFAULT_TEMPLATE_ID,
                  sections: {
                    "std_content00": self.newsletter.template.content
                  }
                }
              }
      response = gb.campaigns(campaign_id).content.upsert(body: body)

    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def update_campaign
    gb = gibbon_request
    begin
      response = gb.campaigns(campaign_id).update({
                       :body => { 
                          :type => "regular", 
                          :recipients =>  {:list_id => list_id}, 
                           :settings => {
                               :subject_line  => subject,           
                               :title         => subject,
                               :reply_to      => reply_email, 
                               :from_name     => from_name }
                       }
                })
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def send_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns(campaign_id).actions.send.create
      true
  	rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
      false
  	end
  end

  def checklist_campaign
    begin
      response = HTTParty.post(V2_URL+"2.0/campaigns/ready", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :cid => campaign_id
                      
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' })
      
      if response.has_key?('is_ready') and !response['is_ready']
        response_str = I18n.t('activerecord.attributes.email_service.not_ready')
        
        response['items'].each do |item|
          if !item.blank? and item.is_a?(Hash) and item['type'] == "cross-large" 
            response_str += "<p>#{item['heading']} - #{item['details']}</p>".html_safe 
          end 
        end
        return response_str
      else
        return false
      end
    rescue Exception => e
      puts e.message
      ApplicationMailer.mailchimp_error(creator, "#{e.message}").deliver_now
    end
  end

  def schedule_campaign
    begin
      response = HTTParty.post(V2_URL+"2.0/campaigns/schedule", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :cid => campaign_id, 
                      :schedule_time => newsletter.scheduled_at.utc.strftime("%Y-%m-%d %H:%M:%S")
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' })
      
      update_attributes(:send_at => newsletter.send_at) if response.has_key?("complete") and response["complete"]
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
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
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
  								  		:address1 => "Q3 Tech",
  								  		:city     => "Gurgaon",
  								  		:state    => "Haryana",
  								  		:zip      => "122017",
  								  		:country  => "India"
  								  	},
  								  :permission_reminder => I18n.t('words.permission_reminder'),
  								  :campaign_defaults => {
                      :from_name       => from_name,
  								  	:from_email      => reply_email,
  								  	:subject         => subject,
  								  	:language        => I18n.locale.to_s.upcase},
  								  :email_type_option => true,
  								 })

  		self.list_id = response["id"]
  		save
      add_merge_variables
  		self.list_id
  	rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def add_merge_variables
    gb = gibbon_request
    begin
      newsletter.template.profile.extra_fields.each do |extra_field|
        gb.lists(self.list_id).merge_fields.create({
          body: { name: extra_field.field_name, type: 'text', tag: extra_field.field_name.upcase }
        })
      end  
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def self.fetch_lists
  	gb = gibbon_request
  	begin
  		response = gb.lists.retrieve
  	rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def fetch_list
    gb = gibbon_request
    begin
      response = gb.lists(list_id).retrieve
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def members_in_list
    gb = gibbon_request
    begin
      response = gb.lists(list_id).members.retrieve
      response["members"]
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end


  def add_member_to_list(email)
  	gb = gibbon_request
  	begin
      gb.lists(list_id).members.create(body: {email_address: email, status: "subscribed"})

  	rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
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
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
  	end
  end

  def add_members_to_list1
    begin
      emails_arr = []
      newsletter.template.profile.contacts.active.each do |contact|
        emails_arr << {'email' => {'email' => contact.email}, 
                       'merge_vars' => Hash[contact.extra_fields.map {|k,v| [k.upcase, v] }],  
                       'email_type' => 'html' }
      end

      response = HTTParty.post(V2_URL+"2.0/lists/batch-subscribe", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :id => list_id,
                      :batch => emails_arr,
                      :double_optin => false
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )
      if response["error_count"] and response["error_count"] > 0
        email_body = I18n.t('activerecord.attributes.email_service.error_import')
        response['errors'].each do |err|
          email_body += "<p>#{err['email']['email']} - #{err['error']}</p>"
        end

        ApplicationMailer.mailchimp_error(creator, email_body).deliver_now
      end
    rescue Exception => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message}").deliver_now
    end
  end

  def delete_members_from_list(emails)  
    begin
      emails_arr = []
      emails.each do |email|
        emails_arr << {'email' => email}
      end
      response = HTTParty.post(V2_URL+"2.0/lists/batch-unsubscribe", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :id => list_id,
                      :batch => emails_arr,
                      :send_goodbye => false
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )
    rescue Exception => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message}").deliver_now
    end
  end

  def delete_member_from_list(email)
    gb = gibbon_request
    begin
      response = gb.lists(list_id).members(Digest::MD5.hexdigest(email)).delete
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def fetch_clients
    gb = gibbon_request
    begin
      response = gb.lists(list_id).clients.retrieve
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def add_webhook_for_unsubscribe
    begin
      response = HTTParty.post(V2_URL+"2.0/lists/webhook-add", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :id => list_id,
                      # :url => (root_url(:host => 'sperantcrm.com', :subdomain => creator.company.try(:subdomain)) + '/newsletter_emails/unsubscribe').to_s,
                      :url => (root_url(:host => HOST_URL, :subdomain => creator.company.try(:subdomain)) + 'newsletter_emails/unsubscribe').to_s,
                      :actions => {
                        :subscribe => true,
                        :unsubscribe => true,
                        :profile => true,
                        :cleaned => true,
                        :upemail => true,
                        :campaign => true},
                      :sources => {
                        :user => true,
                        :admin => true,
                        :api => true }
                    }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )
    rescue Exception => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message}").deliver_now
    end  
  end

  def delete_list
    gb = gibbon_request
    begin
      response = gb.lists(list_id).delete
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
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
      self

    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
      ApplicationMailer.mailchimp_error(creator, "#{e.message} - #{e.raw_body}").deliver_now
    end
  end

  def update_stats
    begin
      
    rescue Gibbon::MailChimpError => e
      puts "#{I18n.t('activerecord.attributes.email_service.problem')}: #{e.message} - #{e.raw_body}"
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
      self.template_id = response["template_id"] if response.has_key?('template_id')
      save
    rescue Exception => e
      puts e.message
      ApplicationMailer.mailchimp_error(creator, "#{e.raw_body}").deliver_now
    end
    #  curl -H "Content-Type: application/json" -X POST -d '{"apikey":"fe7ef49e4934c504860020bd65e2fdc3-us12","name":"dummy", "html": "example html"}' https://us12.api.mailchimp.com/2.0/templates/add
  end

  def edit_template
  end

  def delete_template
    begin
      response = HTTParty.post(V2_URL+"2.0/templates/del", 
                    :body => { 
                      :apikey => GIBBON_KEY, 
                      :template_id => template_id                    
                      }.to_json,
                    :headers => { 'Content-Type' => 'application/json' } )
      self.template_id = response["template_id"] if response.has_key?('template_id')
      save
    rescue Exception => e
      puts e.message
      ApplicationMailer.mailchimp_error(creator, "#{e.raw_body}").deliver_now
    end
  end

  def delete_dependencies
    delete_campaign
    delete_list
    delete_template
  end
  
  def gibbon_request
  	Gibbon::Request.new(api_key: GIBBON_KEY)
  end
end
