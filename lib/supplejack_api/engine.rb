require 'rails'
require 'devise'
require 'sunspot'
require 'mongoid'
require 'mongoid_auto_inc'
require 'mongoid/tree'
require 'strong_parameters'
require 'active_model_serializers'
require 'figaro'
require 'unicode_utils'
require 'rest_client'

module SupplejackApi
  class Engine < ::Rails::Engine
    isolate_namespace SupplejackApi
    engine_name 'supplejack_api'

    config.generators do |g|
      g.test_framework      :rspec,        fixture: false
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
      g.assets false
      g.helper false
    end
  end
end