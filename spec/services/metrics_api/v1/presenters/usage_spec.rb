require 'spec_helper'

module MetricsApi
  module V1
    module Presenters
      describe Usage, focus: true do
        let(:usage_metric){create(:usage_metrics)}
        let(:presenter){Usage.new(usage_metric)}
        let(:result){presenter.to_json}

        it 'matches the expected API response' do
          expect(result).to match_response_schema('metrics/usage')
        end
      end
    end
  end
end
