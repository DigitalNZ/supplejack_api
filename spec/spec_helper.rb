# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rails/application'
require 'rails/mongoid'
require 'rspec/rails'
require 'factory_girl_rails'

require 'timecop'
require 'sunspot_matchers'

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    Rails.cache.clear
  end

  config.before(:each) do
    DatabaseCleaner.clean
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    Timecop.return
    
    Schema.stub(:default_role) { double(:role, name: :developer) }
    Schema.stub_chain(:roles, :keys) { [:developer] }
  end

  config.include SunspotMatchers
end