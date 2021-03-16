

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
require 'factory_bot_rails'
require 'timecop'
require 'sunspot_matchers'
# require 'simplecov'
require 'rspec/active_model/mocks'
require 'sunspot_test/rspec'
require 'rails-controller-testing'

Rails::Controller::Testing.install
# require "codeclimate-test-reporter"
# CodeClimate::TestReporter.start
# SimpleCov.start

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.formatter = :documentation
  config.mock_with :rspec
  config.infer_spec_type_from_file_location!
  config.infer_base_class_for_anonymous_controllers = false
  config.order = 'random'
  # Ignore focus on CI
  config.filter_run focus: true unless ENV['CI']
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = 'spec/examples.txt'

  require 'database_cleaner'
  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    # We have added this as database cleaner appears to not be working for mongo
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
    SupplejackApi.config.record_class.destroy_all
    SupplejackApi::Concept.destroy_all
    DatabaseCleaner.clean
    Timecop.return

    %w(record concept).each do |model|
      klass = "#{model.capitalize}Schema".constantize

      allow(klass).to receive(:default_role) { double(:role, name: :developer) }
    end
  end

  config.include SunspotMatchers
  config.include FactoryBot::Syntax::Methods
end
