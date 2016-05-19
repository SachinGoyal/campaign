namespace :newsletter do
  desc "Send Unset Newsletters as per schedule"
  task scheduled_send: :environment do
    puts "123"
  	Newsletter.scheduled.unsent.each do |newsletter|
  		email_service = newsletter.email_service
      puts newsletter.scheduled_at
      puts Time.zone.now
      puts newsletter.scheduled_at.between?(Time.zone.now - 5.minutes, Time.zone.now)
    	if newsletter.scheduled_at.between?(Time.zone.now - 5.minutes, Time.zone.now) and email_service.members_in_list.count > 0
    		es = newsletter.email_service
        es.update_content
        checklist_fail = es.checklist_campaign
        if checklist_fail
          ApplicationMailer.mailchimp_error(es.creator, "#{checklist_fail}").deliver_now
        else
          es.send_campaign
          newsletter.mark_sent
        end  
  		end
  	end
  end	
end