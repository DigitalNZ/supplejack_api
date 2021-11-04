# frozen_string_literal: true

module SupplejackApi
  class DailyMetricsSerializer < SupplejackApi::BaseSerializer
    attribute :total_public_sets
    attribute :date, key: :day
  end
end
