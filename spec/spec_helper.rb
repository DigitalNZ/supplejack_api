# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'

begin
  require 'pry'
rescue LoadError
end

require File.expand_path("../dummy/config/environment.rb", __FILE__)
require 'rails/application'
require 'rails/mongoid'
require 'rspec/rails'
require 'factory_girl_rails'
require 'timecop'
require 'sunspot_matchers'
require 'mongoid-rspec'
require 'simplecov'
require 'rspec/active_model/mocks'

require "codeclimate-test-reporter"
CodeClimate::TestReporter.start
# SimpleCov.start

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.order = "random"
  # Ignore focus on CI
  config.filter_run focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.clean
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    Timecop.return

    %w(record concept).each do |model|
      klass = "#{model.capitalize}Schema".constantize

      allow(klass).to receive(:default_role) { double(:role, name: :developer) }
      allow(klass).to receive_message_chain(:roles, :keys) { [:developer] }
    end
  end

  config.include SunspotMatchers
  config.include Mongoid::Matchers
  config.include FactoryGirl::Syntax::Methods
end
