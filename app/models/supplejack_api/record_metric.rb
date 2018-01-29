# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/record_metric.rb
  class RecordMetric
    include Mongoid::Document

    field :date,                 type: Date
    field :record_id,            type: Integer
    field :page_views,           type: Integer
    field :user_set_views,       type: Integer
    field :added_to_user_sets,   type: Integer
    field :source_clickthroughs,  type: Integer
    field :appeared_in_searches, type: Integer
  end
end
