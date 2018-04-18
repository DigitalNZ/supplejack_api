# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class ActivitySerializer < ActiveModel::Serializer
      attributes :created_at, :updated_at, :date,
                 :user_sets, :search, :records, :source_clicks, :total
    end
  end
end
