require 'spec_helper'

module MetricsApi
  module V3
    module Presenters
      describe ApiResponse do
        let(:sub_metric_objects) do
          [
            {
              metric: 'display_collection',
              models: [
                {
                  id: 'test',
                  total_active_records: 10,
                  total_new_records: 2,
                  category_counts: {
                    '1' => 10
                  },
                  copyright_counts: {
                    '1' => 10
                  }
                }
              ]
            },
            {
              metric: 'usage',
              models: [
                id: 'test2',
                searches: 5,
                record_page_views: 2,
                user_set_views: 10,
                total: 17
              ]
            }
          ]
        end
        let(:metrics_information) do 
          {
            day: Date.current,
            total_active_records: 10,
            total_new_records: 2
          }
        end
        let(:presenter){ApiResponse.new(metrics_information, sub_metric_objects)}
        let(:result){presenter.to_json}

        it 'matches the expected API response' do
          expect(result).to match_response_schema('metrics/metric')
        end
      end
    end
  end
end
