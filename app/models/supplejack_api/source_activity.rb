# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
