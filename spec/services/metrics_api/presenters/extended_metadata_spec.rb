# frozen_string_literal: true

require 'spec_helper'

module MetricsApi
  module Presenters
    describe ExtendedMetadata do
      let(:presenter) { ExtendedMetadata.new(@models, Time.now.utc.yesterday.to_date, Time.now.utc.to_date) }

      before do
        @models = [
          {
            metric: 'view',
            models: {
              Time.now.utc.to_date => [
                create(:collection_metric, dc: 'test1'),
                create(:collection_metric, dc: 'test2')
              ],
              Time.now.utc.yesterday.to_date => [
                create(:collection_metric, created_at: Time.now.utc.yesterday.to_date.midday)
              ]
            }
          },
          {
            metric: 'record',
            models: {
              Time.now.utc.to_date => [
                create(:faceted_metrics)
              ],
              Time.now.utc.yesterday.to_date => [
                create(:faceted_metrics, date: Time.now.utc.yesterday.to_date)
              ]
            }
          },
          {
            metric: 'top_records',
            models: {
              Time.now.utc.to_date => [
                create(:top_collection_metric, results: { 123 => 456, 345 => 678 }, date: Time.now.utc.to_date)
              ],
              Time.now.utc.yesterday.to_date => [
                create(:top_collection_metric, results: { 910 => 123, 456 => 789 }, date: Time.now.utc.yesterday)
              ]
            }
          }
        ]
      end

      it 'presents them' do
        json = presenter.to_json

        expect(json.length).to eq(2)
        expect(json.first[:date]).to eq(Time.now.utc.yesterday.to_date)
        expect(json.last[:date]).to eq(Time.now.utc.to_date)
        expect(json.first['record'].length).to eq(1)
        expect(json.first['view'].length).to eq(1)
        expect(json.first['top_records'].length).to eq(1)
      end
    end
  end
end
