require 'spec_helper'

module SupplejackApi
  describe MetricsApiController, type: :controller do

    def create_daily_item_metric(day = Date.current, number_of_display_collections = 2)
      display_collection_attributes = number_of_display_collections.times.map do
          {
            name: Faker::Company.name,
            total_active_records: 1,
            total_new_records: 1,
            category_counts: {'stuff' => 1},
            copyright_counts: {'rights' => 1}
          }
      end
      DailyItemMetric.create(
        day: day,
        total_active_records: 30,
        display_collection_metrics_attributes: display_collection_attributes
      )
    end

    describe 'GET endpoint' do
      before do

      end
    end
  end
end
