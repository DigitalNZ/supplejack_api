# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.required_ruby_version = '>= 3.2.2'

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

  s.add_dependency 'active_model_serializers'
  s.add_dependency 'activemodel-serializers-xml'
  s.add_dependency 'dalli'
  s.add_dependency 'devise'
  s.add_dependency 'devise-token_authenticatable', '>= 1.0.0'
  s.add_dependency 'dimensions'
  s.add_dependency 'kaminari'
  s.add_dependency 'kaminari-mongoid'
  s.add_dependency 'lazy_high_charts'
  s.add_dependency 'mimemagic'
  s.add_dependency 'mongoid', '~> 7.4.0'
  s.add_dependency 'mongoid_auto_increment'
  s.add_dependency 'progressbar'
  s.add_dependency 'pundit', '~> 2.1'
  s.add_dependency 'rails', '>= 7.0.6', '< 7.2.0'
  s.add_dependency 'responders'
  s.add_dependency 'rest-client'
  s.add_dependency 'sidekiq'
  s.add_dependency 'sprockets-rails'
  s.add_dependency 'state_machines'
  s.add_dependency 'thin'
  s.add_dependency 'unicode_utils'
  s.add_dependency 'voight_kampff', '~> 2.0'

  # Adding sunspot_solr so app has access to sunspot:solr rake tasks
  s.add_dependency 'activeresource'
  s.add_dependency 'activeresource-response'
  s.add_dependency 'json-ld'
  s.add_dependency 'rufus-scheduler'
  s.add_dependency 'sunspot_rails'
  s.add_dependency 'sunspot_solr'

  # Development dependancies
  s.add_development_dependency 'better_errors'
  s.add_development_dependency 'binding_of_caller'
  s.add_development_dependency 'database_cleaner-mongoid'
  s.add_development_dependency 'factory_bot_rails'
  s.add_development_dependency 'json_spec'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rails'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rails'
  s.add_development_dependency 'sunspot_matchers'
  s.add_development_dependency 'sunspot_test'
  s.add_development_dependency 'timecop'
  s.add_development_dependency 'web-console'
  s.add_development_dependency 'yard'
end
