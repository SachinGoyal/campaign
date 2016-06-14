class ApplicationMailer < ActionMailer::Base
  default from: Setting.first.try(:admin_email) || "from@example.com"
  layout 'mailer'

  def mailchimp_error(user, message)
  	 @user = user
  	 @message = message
  	 mail(to: @user.email, subject: 'Error en MailChimp')
  end
end
