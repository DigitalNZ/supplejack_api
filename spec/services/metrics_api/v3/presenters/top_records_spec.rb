require 'spec_helper'
require 'json'

module MetricsApi
  module V3
    module Presenters
      describe TopRecords do
        let(:presenter){ TopRecords.new(@model) }

        before do
          @model = create(:top_metric, results: { 1 => 2, 3 => 4})
        end

        it 'presents them' do
          json = presenter.to_json

          expect(json.length).to eq(1)
          expect(json['pages_views']).to eq({1=>2, 3=>4})
        end
      end
    end
  end
end
