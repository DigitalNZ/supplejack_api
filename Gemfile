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

# jquery-rails is used by the dummy application
gem 'jquery-rails'

# Xml doesn't get support in AMS, this is an existing fork
gem 'active_model_serializers', git: 'https://github.com/boost/active_model_serializers'
gem 'mongoid_auto_inc', git: 'https://github.com/boost/mongoid_auto_inc.git'

# Must add 'require' statments in Gemfile
gem 'mongoid-tree', require: 'mongoid/tree'
gem 'resque-scheduler', require: 'resque_scheduler'
gem 'dimensions', require: false
gem 'mimemagic', require: false
gem 'rb-fsevent', require: false
gem 'cucumber-rails', require: false
gem 'factory_girl_rails', require: false
gem 'simplecov', require: false
gem 'xml_spec', git: "https://github.com/boost/xml_spec", require: false # This is a gem created by fedegl to test the XML responses, its part of the Boost github organization account
gem 'codeclimate-test-reporter', group: :test, require: nil
