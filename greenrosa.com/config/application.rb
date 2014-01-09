require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env) if defined?(Bundler)
end


module Greenrosa

  class Application < Rails::Application
    config.secret_token = ''
   
  end
end