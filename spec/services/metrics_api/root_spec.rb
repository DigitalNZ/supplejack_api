# frozen_string_literal: true

require 'spec_helper'

module MetricsApi
  describe Root do
    let(:extended) do
      Root.new(
        { facets: @facets,
          start_date: @start_date,
          end_date: @end_date,
          metrics: @metrics }
      )
    end

    context 'Metrics' do
      before do
        @facets = 'dc1,dc2'
        @start_date = Time.now.utc.to_date.strftime
        @end_date = Time.now.utc.to_date.strftime
        @metrics = 'view,record'

        create(:faceted_metrics, name: 'dc1')
        create(:faceted_metrics, name: 'dc2')
        create(:collection_metric, display_collection: 'dc1',
                                   created_at: Time.now.utc.to_date.midday,
                                   date: Time.now.utc.to_date)
        create(:collection_metric, display_collection: 'dc2',
                                   created_at: Time.now.utc.to_date.midday,
                                   date: Time.now.utc.to_date)
      end

      describe '#call' do
        it 'retrieves a range of metrics' do
          result = extended.call

          expect(result.first[:date]).to eq(Time.now.utc.to_date)
          expect(result.first['record'].length).to eq(2)
          expect(result.first['view'].length).to eq(2)
        end

        it 'filters metrics based on the facets argument' do
          @facets = 'dc1'
          result = extended.call

          expect(result.first[:date]).to eq(Time.now.utc.to_date)
          expect(result.first['record'].length).to eq(1)
          expect(result.first['view'].length).to eq(1)
        end
      end
    end
  end
end
