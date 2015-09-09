require 'spec_helper'

module MetricsApi
  module V1
    module MetricsLoaders
      describe DisplayCollections, focus: true do
        let(:loader){DisplayCollections.new}
        let(:result){loader.call(Date.current - 4.days, Date.current)}

        before do
          5.times do |n|
            create(:daily_item_metric, day: Date.current - n.days)
          end
        end

        it 'retrieves a range of display_collections' do
          expected_count = SupplejackApi::DailyItemMetric.all.take(5).map(&:display_collection_metrics).flatten.length
          expect(result.length).to eq(expected_count)
        end

        it 'presents each display_collection for the api' do
          result.each do |r|
            expect(r).to match_response_schema('metrics/display_collection')
          end
        end
      end
    end
  end
end
