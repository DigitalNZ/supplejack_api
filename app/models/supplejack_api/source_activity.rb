# frozen_string_literal: true



module SupplejackApi
  class SourceActivity
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: 'source_activities'

    field :source_clicks,	type: Integer, default: 0

    private_class_method :new

    def self.increment
      if first
        first.inc(source_clicks: 1)
      else
        SupplejackApi::SourceActivity.create(source_clicks: 1)
      end
    end

    def self.get_source_clicks
      SupplejackApi::SourceActivity.first.try(:source_clicks)
    end

    def self.reset
      SupplejackApi::SourceActivity.first.try(:delete)
    end
  end
end
