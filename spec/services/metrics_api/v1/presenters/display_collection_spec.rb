require 'spec_helper'

module MetricsApi
  module V1
    module Presenters
      describe DisplayCollection do
        let(:daily_item_metric){create(:daily_item_metric)}
        let(:presenter){DisplayCollection.new(daily_item_metric)}
        let(:result){presenter.to_json}

        it 'matches the expected API response' do
          expect(result).to match_response_schema('metrics/display_collections')
        end
      end
    end
  end
end
