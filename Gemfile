# frozen_string_literal: true

source 'http://rubygems.org'

# Declare your gem's dependencies in supplejack_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'dimensions', require: false
gem 'jquery-rails'
gem 'mimemagic', require: false
gem 'rubocop', require: false
gem 'yard', require: false, group: :development
# # This is a gem created by fedegl to test the XML responses, its part of the Boost github organization account
gem 'xml_spec', git: 'https://github.com/boost/xml_spec',  require: false

group :test do
  gem 'faker'
  gem 'json-schema'
end
