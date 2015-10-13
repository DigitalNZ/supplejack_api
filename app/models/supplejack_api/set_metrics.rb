module SupplejackApi
  class SetMetrics
    include Mongoid::Document
    include Mongoid::Timestamps

    field :day,                 type: Date
    field :total_records_added, type: Integer, default: 0
    field :facet,               type: String
  end
end
