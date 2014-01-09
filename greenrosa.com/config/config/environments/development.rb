require 'collaborator_values'
include CollaboratorValues
CollaboratorMethods.load_values


Greenrosa::Application.configure do

  config.whiny_nils = true

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.session_store(:active_record_store)

  config.action_view.debug_rjs             = true
  config.log_level = :debug
  config.autoload_paths += %W( #{Rails.root}/collaborator)
  config.autoload_paths += %W( #{Rails.root}/collaborator/source_files)
  #  config.action_controller.perform_caching = false
  #config.middleware.clear
  config.active_record.observers = :feature_observer, :alternative_observer, :user_observer
  config.action_mailer.default_charset = "utf-8"
  config.action_mailer.default_content_type = "text/html"


  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  #  # See application.rb
  #  # :enable_starttls_auto => true,
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => "" ,
    :port => 587,
    :domain => "",
    :authentication => :login,
    :user_name =>  "",
    :password =>  ""
  }

    # Print deprecation notices to the Rails logger
    config.active_support.deprecation = :log
    # config.assets.enabled = true
    # Only use best-standards-support built into browsers
    #  config.action_dispatch.best_standards_support = :builtin


  end

