# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '3.2.13' unless defined? RAILS_GEM_VERSION
# Load the rails application
require File.expand_path('../application', __FILE__)

Greenrosa::Application.initialize!

