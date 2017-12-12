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

gem 'codeclimate-test-reporter', group: :test, require: nil
gem 'dimensions', require: false
gem 'jquery-rails'
gem 'mimemagic', require: false
gem 'mongoid-tree', require: 'mongoid/tree'
gem 'rubocop', require: false
gem 'yard', require: false, group: :development
# # This is a gem created by fedegl to test the XML responses, its part of the Boost github organization account
gem 'xml_spec', git: 'https://github.com/boost/xml_spec',  require: false

group :test do
  gem 'faker'
  gem 'json-schema'
end
