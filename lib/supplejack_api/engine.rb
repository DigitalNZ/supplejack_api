require 'rails'
require 'devise'
require 'kaminari'
require 'simple_form'
require 'state_machine'
require 'sunspot'
require 'active_model_serializers'
require 'mongoid'
require 'mongoid_auto_inc'
require 'mongoid/tree'
require 'devise/orm/mongoid'
require 'strong_parameters'
require 'figaro'
require 'unicode_utils'
require 'rest_client'
require 'lazy_high_charts'

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
