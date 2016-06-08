Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.action_mailer.default_url_options = { host: 'sperantcrm.com' }
  config.cache_classes = false
  # config.action_mailer.default_url_options = { host: "lvh.me:3000" }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp

  ActionMailer::Base.default(from: 'support@sperantcrm.com')

  ActionMailer::Base.smtp_settings = {
    :port           => 587,
    :address        => "smtp.mandrillapp.com",
    :user_name      => "app10453745@heroku.com",
    :password       => "109lRaN59Bb7HKkssiTTnA",
    :domain         => 'sperantcrm.com',
    :authentication => :plain,
  }
  ActionMailer::Base.delivery_method = :smtp
  # Code is not reloaded between requests.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false
  config.log_level = :info
  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  config.serve_static_files = true

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.compile = true
  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true
  config.i18n.fallbacks = true
  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true
end
