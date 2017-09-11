# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

source 'http://rubygems.org'

# Declare your gem's dependencies in supplejack_api.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

gem 'active_model_serializers'
gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'cucumber-rails', require: false
gem 'dimensions', require: false
gem 'factory_girl_rails', require: false
# jquery-rails is used by the dummy application
gem 'jquery-rails'
gem 'mimemagic', require: false
gem 'mongoid_auto_inc', git: 'https://github.com/boost/mongoid_auto_inc.git'
# Must add 'require' statments in Gemfile
gem 'mongoid-tree', require: 'mongoid/tree'
gem 'rb-fsevent', require: false
gem 'rubocop', require: false
gem 'simplecov', require: false
gem 'yard', require: false, group: :development
gem 'sunspot_rails', '~> 2.2.7'
gem 'sunspot_solr', '~> 2.2.7'
# This is a gem created by fedegl to test the XML responses, its part of the Boost github organization account
gem 'xml_spec', git: 'https://github.com/boost/xml_spec', require: false

group :test do
  gem 'faker'
  gem 'json-schema'
end
