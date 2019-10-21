# frozen_string_literal: true

module SupplejackApi
  class UsageMetrics
    include Mongoid::Document
    include Mongoid::Timestamps
    include SupplejackApi::Concerns::QueryableByDate

    store_in collection: 'usage_metrics'

    field :record_field_value,         type: String
    field :searches,                   type: Integer, default: 0
    field :gets,                       type: Integer, default: 0
    field :user_set_views,             type: Integer, default: 0
    field :total_views,                type: Integer, default: 0
    field :records_added_to_user_sets, type: Integer, default: 0
    field :date,                       type: Date
  end
end
