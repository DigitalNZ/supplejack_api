# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'supplejack_api'
  s.version     = '1'
  s.authors     = ['DigitalNZ']
  s.email       = ['info@digitalnz.org']
  s.homepage    = 'http://digitalnz.org'
  s.summary     = 'Supplejack API'
  s.description = 'Supplejack API'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '5.1.4'
  s.add_dependency 'responders'
  s.add_dependency 'thin'
  s.add_dependency 'kaminari'
  s.add_dependency 'kaminari-mongoid'
  s.add_dependency 'unicode_utils'
  s.add_dependency 'rest-client'
  s.add_dependency 'state_machine'
  s.add_dependency 'devise'
  s.add_dependency 'devise-token_authenticatable', '<= 1.0.0'
  s.add_dependency 'active_model_serializers'
  s.add_dependency 'activemodel-serializers-xml'
  s.add_dependency 'paperclip'
  s.add_dependency 'progressbar'
  s.add_dependency 'dimensions'
  s.add_dependency 'mimemagic'
  s.add_dependency 'dalli'
  s.add_dependency 'simple_form'
  s.add_dependency 'lazy_high_charts'
  s.add_dependency 'figaro'
  s.add_dependency 'jquery-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'uglifier'
  s.add_dependency 'compass-rails'
  s.add_dependency 'zurb-foundation'
  s.add_dependency 'gabba'
  s.add_dependency 'mongoid'
  s.add_dependency 'mongoid_auto_increment'
  s.add_dependency 'mongoid-tree'
  s.add_dependency 'sidekiq'
  s.add_dependency 'dry-validation'
  s.add_dependency 'dry-struct'

  # # Adding sunspot_solr so app has access to sunspot:solr rake tasks
  s.add_dependency 'sunspot_rails'
  s.add_dependency 'sunspot_solr'
  s.add_dependency 'json-ld'
  s.add_dependency 'activeresource'
  s.add_dependency 'rufus-scheduler'

  # ## Development dependancies
  s.add_development_dependency 'web-console'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'database_cleaner'
  # s.add_development_dependency 'mongoid-rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'json_spec'
  s.add_development_dependency 'sunspot_matchers'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sunspot_test'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rails-controller-testing'

  if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
  end

end
