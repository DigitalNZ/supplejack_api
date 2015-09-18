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
                  create(:usage_metrics),
                  create(:usage_metrics)
                ],
                Date.yesterday => [
                  create(:usage_metrics, created_at: Date.yesterday.midday)
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
                  create(:faceted_metrics, day: Date.yesterday)
                ]
              }
            }
          ]
        end

        it 'presents them' do
          json = presenter.to_json

          expect(json.length).to eq(2)
          expect(json.first[:day]).to eq(Date.yesterday)
          expect(json.last[:day]).to eq(Date.current)
          expect(json.first['record'].length).to eq(1)
          expect(json.first['view'].length).to eq(1)
        end
      end
    end
  end
end
