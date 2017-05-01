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

  s.add_dependency 'rails', '~> 4.1.0'
  s.add_dependency 'protected_attributes'
  s.add_dependency 'thin', '~> 1.6.2'
  s.add_dependency 'kaminari', '~> 0.14.0'
  s.add_dependency 'unicode_utils', '~> 1.4.0'
  s.add_dependency 'rest-client', '~> 1.6.7'
  s.add_dependency 'state_machine', '~> 1.1.2'
  s.add_dependency 'devise', '~> 3.4.1'
  s.add_dependency 'devise-token_authenticatable', '~> 0.3.0'
  s.add_dependency 'active_model_serializers'
  s.add_dependency 'paperclip', '~> 3.1.4'
  s.add_dependency 'progressbar', '~> 0.11.0'
  s.add_dependency 'dimensions', '~> 1.2.0'
  s.add_dependency 'mimemagic', '~> 0.1.8'
  s.add_dependency 'dalli', '~> 1.1.2'
  s.add_dependency 'simple_form', '~> 3.0.2'
  s.add_dependency 'lazy_high_charts', '~> 1.5.4'
  s.add_dependency 'figaro', '~> 0.7.0'
  s.add_dependency 'jquery-rails', '~> 3.1.0'
  s.add_dependency 'sass-rails', '~> 4.0.3'
  s.add_dependency 'coffee-rails', '~> 4.0.0'
  s.add_dependency 'uglifier', '~> 2.5.0'
  s.add_dependency 'therubyracer', '~> 0.12.0'
  s.add_dependency 'compass-rails', '~> 1.0.3'
  s.add_dependency 'zurb-foundation', '~> 4.3.2'
  s.add_dependency 'gabba', '~> 0.3.0'
  s.add_dependency 'mongoid', '~> 4.0.0'
  s.add_dependency 'mongoid_auto_inc', '~> 0.1.0'
  s.add_dependency 'mongoid-tree', '~> 1.0.0'
  s.add_dependency 'sidekiq', '~> 4.2'
  s.add_dependency 'dry-validation', '~> 0.10.0'
  s.add_dependency 'dry-struct'

  # Adding sunspot_solr so app has access to sunspot:solr rake tasks
  s.add_dependency 'json-ld', '~> 1.1.4'
  s.add_dependency 'activeresource'
  s.add_dependency 'rufus-scheduler', '= 2.0.17'

  ## Development dependancies
  s.add_development_dependency 'rspec-rails', '~> 3.1.0'
  s.add_development_dependency 'cucumber-rails', '~> 1.3.0'
  s.add_development_dependency 'capybara', '~> 2.2.0'
  s.add_development_dependency 'launchy', '~> 2.1.2'
  s.add_development_dependency 'factory_girl_rails', '~> 4.0.0'
  s.add_development_dependency 'database_cleaner', '~> 1.5.3'
  s.add_development_dependency 'mongoid-rspec', '~> 2.0.0.rc1'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'json_spec', '~> 1.1.4'
  s.add_development_dependency 'sunspot_matchers', '~> 2.2.5.0'
  s.add_development_dependency 'timecop', '~> 0.4.6'
  s.add_development_dependency 'binding_of_caller', '~> 0.7.1'
  s.add_development_dependency 'rb-fsevent', '~> 0.9.1'
  s.add_development_dependency 'simplecov', '~> 0.6.4'
  s.add_development_dependency 'sunspot_test', '~> 0.4.0'
  s.add_development_dependency 'rspec-activemodel-mocks', '~> 1.0.1'

  if RUBY_VERSION =~ /1.9/
    Encoding.default_external = Encoding::UTF_8
    Encoding.default_internal = Encoding::UTF_8
  end

end
