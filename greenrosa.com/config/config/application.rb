require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(:default, Rails.env) if defined?(Bundler)
end


module Greenrosa

  class Application < Rails::Application
    config.secret_token = '7dac61f38e988e3b9c679780f1a90a21c3960ac7d465d5b6374e8a08639411cf95f9722b7e115849ae902fbe0c8a80bc26d0871d1c5a24439555sdfsddf5d21369'
   
  end
end