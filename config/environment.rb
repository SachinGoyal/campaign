# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.smtp_settings = {
# :address => "smtp.gmail.com",
# :port => 587,
# :domain => "gmail.com",
# :user_name => "sachinidify@gmail.com" ,
# :password => "sachin@123",
# :authentication => "plain",
# :enable_starttls_auto => true
# }