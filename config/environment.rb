# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!
 ActionMailer::Base.delivery_method = :smtp
   ActionMailer::Base.smtp_settings = {
    :address        => 'smtp.sendgrid.net',
    :port           => '587',
    :authentication => :plain,
    :user_name      => 'app10453745@heroku.com',
    :password       => '2pxudzpr4491',
    :domain         => 'eterniasoft.com',
  }