# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/collection_summary_metric.rb
  class CollectionSummaryMetric
    include Mongoid::Document

    field :d, as: :date,                           type: Date,    default: Time.zone.today
    field :f, as: :facet,                          type: String
    field :s, as: :searches,                       type: Integer, default: 0
    field :rpv, as: :record_page_views,            type: Integer, default: 0
    field :usetv, as: :user_set_views,             type: Integer, default: 0
    field :ustoryv, as: :user_story_views,         type: Integer, default: 0
    field :tv, as: :total_views,                   type: Integer, default: 0
    field :ratus, as: :records_added_to_user_sets, type: Integer, default: 0
    field :tsc, as: :total_source_clickthroughs,   type: Integer, default: 0

    validates :facet, presence: true
    validates :facet, uniqueness: { scope: :date }
  end
end
