require File.expand_path('../boot', __FILE__)
require 'iconv'
require 'csv'
require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CampaignApp
  class Application < Rails::Application
    # config.middleware.use 'Apartment::Elevators::Subdomain'
    # config.assets.paths << Rails.root.join('app', 'assets', 'fonts')
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'  "Asia/Kolkata"
    config.time_zone = 'Lima'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :es
    I18n.locale = config.i18n.locale = config.i18n.default_locale

    # config.action_view.embed_authenticity_token_in_remote_forms = true
#    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.paths << Rails.root.join("app", "assets", "fonts", "images")
    config.assets.precompile += %w( *.js *.coffee *.css *.scss  .svg .png .eot .woff .woff2 .ttf )    
    config.to_prepare do
      Devise::SessionsController.skip_before_filter :check_subdomain
    end
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
