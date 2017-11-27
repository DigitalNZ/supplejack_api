# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'rails'
require 'devise'
require 'devise-token_authenticatable'
require 'kaminari'
require 'kaminari/mongoid'
require 'simple_form'
require 'state_machine'
require 'sunspot'
require 'active_model_serializers'
require 'mongoid'
require 'mongoid_auto_increment'
require 'mongoid/tree'
require 'devise/orm/mongoid'
require 'figaro'
require 'unicode_utils'
require 'rest_client'
require 'lazy_high_charts'
require 'sidekiq'
require 'json/ld'
require 'dry-validation'

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
      ApplicationController.helper(ActionView::Helpers::ApplicationHelper)
    end
  end

  def self.setup(&block)
    config.record_class = Record
    config.preview_record_class = PreviewRecord

    @config ||= SupplejackApi::Engine::Configuration.new
    yield @config if block
  end

  def self.config
    Rails.application.config
  end
end
