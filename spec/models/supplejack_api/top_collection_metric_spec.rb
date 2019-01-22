require 'spec_helper'

RSpec.describe SupplejackApi::TopCollectionMetric, type: :model do
  let(:top_collection_metric) { create(:top_collection_metric, results: { 1 => 200, 2 => 150 }) }

  describe '#attributes' do
    it 'has a date' do
      expect(top_collection_metric.date).to eq Time.zone.now.utc.to_date
    end

    it 'has a metric' do
      expect(top_collection_metric.metric).to eq 'appeared_in_searches'
    end

    it 'has results' do
      results = { 1 => 200, 2 => 150 }
      expect(top_collection_metric.results).to eq results
    end
  end

  describe '::spawn' do
    let!(:metric_one)   { create(:record_metric, appeared_in_searches: 1, date: Time.zone.yesterday, display_collection: 'Gotta collect them all!') }
    let!(:metric_two)   { create(:record_metric, appeared_in_searches: 2, date: Time.zone.yesterday, display_collection: 'Supplejack LTD') }
    let!(:metric_three) { create(:record_metric, appeared_in_searches: 3, date: Time.zone.yesterday, display_collection: 'Collecty McCollectyface') }

    let!(:metric_group) { create_list(:record_metric, 250, date: Time.zone.yesterday, page_views: 1, display_collection: 'Laramie') }
    let!(:yesterdays_metric_group) { create_list(:record_metric, 5, date: Time.zone.yesterday - 1.day, page_views: 2, display_collection: 'Laramie') }

    context 'metrics logging is disabled' do
      it 'returns nil' do
        allow(SupplejackApi).to receive_message_chain(:config, :log_metrics).and_return(false)

        expect(described_class.spawn).to eq nil
      end
    end

    before do
      # Stub Metrics logger
      allow(Logger).to receive(:new).and_return(nil)
      allow(SupplejackApi::TopCollectionMetric::METRICS_LOGGER).to receive(:info).and_return(nil)

      create(:record_metric, date: Time.zone.yesterday, appeared_in_searches: 1, display_collection: 'Laramie')
      create(:record_metric, date: Time.zone.yesterday, appeared_in_searches: 2, display_collection: 'Laramie')
      create(:record_metric, date: Time.zone.yesterday, appeared_in_searches: 3, display_collection: 'Laramie')
      SupplejackApi::TopCollectionMetric.spawn
    end

    it 'creates TopCollectionMetrics for each metric AND collection' do
      metrics = ['added_to_user_sets', 'added_to_user_stories', 'appeared_in_searches', 'page_views', 'source_clickthroughs', 'user_set_views', 'user_story_views']
      display_collections = described_class.all.map(&:display_collection)

      metrics.each do |metric|
        display_collections.each do |dc|
          expect(SupplejackApi::TopCollectionMetric.where(metric: metric, display_collection: dc)).to exist
        end
      end
    end

    it 'stamps all processed RecordMetric records :processed_by_top_collection_metrics flag as true' do
      SupplejackApi::RecordMetric.all.each do |record_metric|
        expect(record_metric.processed_by_top_collection_metrics).to be true
      end
    end

    it 'only takes the top 200 records for each metric AND collection' do
      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday, metric: 'page_views', display_collection: 'Laramie').results.keys.count).to eq 200
    end

    it 'orders the results from highest to lowest' do
      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday, metric: 'appeared_in_searches', display_collection: 'Laramie').results.values.first).to eq 3
    end

    it 'spawns metrics across multiple days' do
      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday - 1.day, metric: 'page_views', display_collection: 'Laramie').results.keys.count).to eq 5
    end

    it 'sets RecordMetrics :processed_by_top_collection_metrics flag to `true`' do
      [metric_one, metric_two, metric_three].each do |metric|
        expect(metric.reload.processed_by_top_collection_metrics).to be true
      end
    end

    it 'appends new top collection metrics that creep in after the initial run' do
      SupplejackApi::RecordMetric.destroy_all

      create(:record_metric, appeared_in_searches: 1, date: Time.zone.yesterday, record_id: metric_three.record_id, display_collection: 'Laramie')
      create(:record_metric, appeared_in_searches: 1, date: Time.zone.yesterday, display_collection: 'Laramie')

      SupplejackApi::TopCollectionMetric.spawn

      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday, metric: 'appeared_in_searches', display_collection: 'Laramie').results.values.first).to eq 3
      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday, metric: 'appeared_in_searches', display_collection: 'Laramie'))
      expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.zone.yesterday, metric: 'appeared_in_searches', display_collection: 'Laramie').results.keys.count).to eq 200
    end
  end
end
