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
        puts "here"
    		newsletter.email_service.update_content
    		newsletter.email_service.send_campaign
    		newsletter.mark_sent
  		end
  	end
  end	
end