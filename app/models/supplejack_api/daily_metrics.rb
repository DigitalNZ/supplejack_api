# frozen_string_literal: true



module SupplejackApi
  class DailyMetrics
    include Mongoid::Document
    include Mongoid::Timestamps
    include SupplejackApi::Concerns::QueryableByDate

    store_in collection: 'daily_metrics'

    field :total_public_sets, type: Integer
    field :date,               type: Date
  end
end
