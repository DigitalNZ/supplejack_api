module MetricsApi
  module V1
    module MetricsLoaders
      class DisplayCollections
        def call(start_date, end_date)
          metrics = SupplejackApi::DailyItemMetric.created_between(start_date, end_date)

          metrics.map(&:display_collection_metrics).flatten.map(&MetricsApi::V1::Presenters::DisplayCollection)
        end
      end
    end
  end
end
