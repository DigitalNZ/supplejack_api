require 'spec_helper'

module MetricsApi
  module V3
    module Presenters
      describe ExtendedMetadata do
        let(:presenter){ExtendedMetadata.new(@models, Date.yesterday, Date.current)}

        before do
          @models = [
            {
              metric: 'view',
              models: {
                Date.current => [
                  create(:collection_metric, dc: 'test1'),
                  create(:collection_metric, dc: 'test2')
                ],
                Date.yesterday => [
                  create(:collection_metric, created_at: Date.yesterday.midday)
                ]
              }
            },
            {
              metric: 'record',
              models: {
                Date.current => [
                  create(:faceted_metrics),
                ],
                Date.yesterday => [
                  create(:faceted_metrics, date: Date.yesterday)
                ]
              }
            },
            {
              metric: 'top_records',
              models: {
                Date.current => [
                  create(:top_collection_metric, results: { 123 => 456, 345 => 678}, date: Time.zone.today),
                ],
                Date.yesterday => [
                  create(:top_collection_metric, results: { 910 => 123, 456 => 789}, date: Time.zone.yesterday)
                ]
              }
            }
          ]
        end

        it 'presents them' do
          json = presenter.to_json

          expect(json.length).to eq(2)
          expect(json.first[:date]).to eq(Date.yesterday)
          expect(json.last[:date]).to eq(Date.current)
          expect(json.first['record'].length).to eq(1)
          expect(json.first['view'].length).to eq(1)
          expect(json.first['top_records'].length).to eq(1)
        end
      end
    end
  end
end
