# frozen_string_literal: true

require 'rails'
require 'devise'
require 'devise-token_authenticatable'
require 'kaminari'
require 'kaminari/mongoid'
require 'state_machine'
require 'sunspot'
require 'active_model_serializers'
require 'mongoid'
require 'mongoid_auto_increment'
require 'devise/orm/mongoid'
require 'figaro'
require 'unicode_utils'
require 'rest_client'
require 'lazy_high_charts'
require 'sidekiq'
require 'json/ld'
require 'dry-validation'
require 'voight_kampff'

module SupplejackApi
  class Engine < ::Rails::Engine
    isolate_namespace SupplejackApi
    engine_name 'supplejack_api'

    config.generators do |g|
      g.test_framework      :rspec,        fixture: false
      g.fixture_replacement :factory_bot, dir: 'spec/factories'
      g.assets false
      g.helper false
    end

    config.to_prepare do
      Dir.glob(Rails.root.join('app/decorators/**/*_decorator*.rb')).each do |c|
        require_dependency(c)
      end
    end
  end

  def self.setup(&block)
    config.record_class = Record
    config.preview_record_class = PreviewRecord
    config.record_batch_size_for_mongo_queries_and_solr_indexing = 500

    @config ||= SupplejackApi::Engine::Configuration.new
    yield @config if block
  end

  def self.config
    Rails.application.config
  end
end
