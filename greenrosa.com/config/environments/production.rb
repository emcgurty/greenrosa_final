require 'collaborator_values'
include CollaboratorValues
CollaboratorMethods.load_values

Greenrosa::Application.configure do
  config.cache_classes = false

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.session_store(:active_record_store)
  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Full error reports are disabled and caching is turned on
  config.action_controller.consider_all_requests_local = false
  config.action_controller.perform_caching             = false
  
config.time_zone = 'UTC'
  
# where source files will be stored
  
config.autoload_paths += %W( #{Rails.root}/collaborator)
  
config.autoload_paths += %W( #{Rails.root}/collaborator/source_files)
  
config.active_record.observers = :feature_observer, :alternative_observer, :user_observer

config.action_mailer.default_charset = "utf-8"
config.action_mailer.default_content_type = "text/html"
config.action_mailer.raise_delivery_errors = true

config.action_mailer.delivery_method = :smtp

config.action_mailer.smtp_settings = {
    :enable_starttls_auto => false,

    :address => "" ,

    :port => 587,

    :domain => "",

    :authentication => "login",

    :user_name =>  "",

    :password => "",
  :openssl_verify_mode  => "none" }
end
