# == Schema Information
#
# Table name: email_services
#
#  id            :integer          not null, primary key
#  newsletter_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  list_id       :string
#  campaign_id   :string
#  company_id    :integer
#
# Indexes
#
#  index_email_services_on_newsletter_id  (newsletter_id)
#

class EmailService < ActiveRecord::Base
  
  acts_as_tenant(:company) #multitenant
  belongs_to :newsletter

  delegate :name, :subject, :from_address, :from_name, :to => :newsletter

  def create_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns.create({
                       :body => { 
                          :type => "plaintext", 
  									      :recipients =>  {:list_id => list_id}, 
  									       :settings => {
                               :subject_line  => subject,				   	
  									   				 :title         => subject,
  									   				 :reply_to      => from_address, 
  									   				 :from_name     => from_name}
  									   }
  							})
  	
  		self.campaign_id = response["id"]
  		save
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
  	end
  end

  def send_campaign
  	gb = gibbon_request
  	begin
  		response = gb.campaigns(campaign_id).actions.send.create
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
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
  	end
  end

  def fetch_lists
  	gb = gibbon_request
  	begin
  		response = gb.lists.retrieve
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
  	end
  end

  def add_member_to_list
  	gb = gibbon_request
  	begin
  	rescue Gibbon::MailChimpError => e
      puts "We have a problem: #{e.message} - #{e.raw_body}"
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
  	end
  end

  def get_stats
  end

  def add_template
  end

  def edit_template
  end
  
  def gibbon_request
  	Gibbon::Request.new(api_key: GIBBON_KEY)
  end
end
