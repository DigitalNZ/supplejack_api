# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::TopCollectionMetric, type: :model do
  let(:top_collection_metric) { create(:top_collection_metric, results: { 1 => 200, 2 => 150 }) }

  describe '#attributes' do
    it 'has a date' do
      expect(top_collection_metric.date).to eq Time.now.utc.to_date
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
    context 'no args, it defaults to all dates before today' do
      let!(:metric_one) do
        create(:record_metric, appeared_in_searches: 1,
                               date: Time.now.utc.yesterday,
                               display_collection: 'Gotta collect them all!')
      end

      let!(:metric_two) do
        create(:record_metric, appeared_in_searches: 2,
                               date: Time.now.utc.yesterday, display_collection: 'Supplejack LTD')
      end

      let!(:metric_three) do
        create(:record_metric, appeared_in_searches: 3,
                               date: Time.now.utc.yesterday, display_collection: 'Collecty McCollectyface')
      end

      let!(:metric_group) do
        create_list(:record_metric, 250, date: Time.now.utc.yesterday, page_views: 1, display_collection: 'Laramie')
      end

      let!(:yesterdays_metric_group) do
        create_list(:record_metric, 5, date: Time.now.utc.yesterday - 1.day,
                                       page_views: 2,
                                       display_collection: 'Laramie')
      end

      before do
        described_class::METRICS.each do |metric|
          create(:record_metric, date: Time.now.utc.yesterday, metric.to_sym => 1, display_collection: 'Laramie')
        end

        create(:record_metric, date: Time.now.utc.yesterday, appeared_in_searches: 1, display_collection: 'Laramie')
        create(:record_metric, date: Time.now.utc.yesterday, appeared_in_searches: 2, display_collection: 'Laramie')
        create(:record_metric, date: Time.now.utc.yesterday, appeared_in_searches: 3, display_collection: 'Laramie')
        SupplejackApi::TopCollectionMetric.spawn
      end

      it 'stamps all processed RecordMetric records :processed_by_top_collection_metrics flag as true' do
        SupplejackApi::RecordMetric.all.each do |record_metric|
          expect(record_metric.processed_by_top_collection_metrics).to be true
        end
      end

      it 'only takes the top 200 records for each metric AND collection' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'page_views',
                                                          display_collection: 'Laramie').results.keys.count).to eq 200
      end

      it 'orders the results from highest to lowest' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.first).to eq 3
      end

      it 'spawns metrics across multiple days' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday - 1.day,
                                                          metric: 'page_views',
                                                          display_collection: 'Laramie').results.keys.count).to eq 5
      end

      it 'sets RecordMetrics :processed_by_top_collection_metrics flag to `true`' do
        [metric_one, metric_two, metric_three].each do |metric|
          expect(metric.reload.processed_by_top_collection_metrics).to be true
        end
      end

      it 'appends new top collection metrics that creep in after the initial run' do
        SupplejackApi::RecordMetric.destroy_all

        create(:record_metric, appeared_in_searches: 1,
                               date: Time.now.utc.yesterday,
                               record_id: metric_three.record_id,
                               display_collection: 'Laramie')

        create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.yesterday, display_collection: 'Laramie')

        described_class.spawn

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.first).to eq 3

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie'))

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.keys.count).to eq 6
      end

      it 'returns a collection of top collection metrics' do
        described_class.spawn.each do |tcm|
          expect(tcm.class).to eql described_class
        end
      end

      it 'does not include records that have 0 of the requested metric in the results' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.uniq)
          .not_to include 0
      end

      it 'only includes records that have valid data' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.yesterday,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.count).to eq 4
      end

      it 'doesn\'t create top collection metrics when there are no results' do
        expect(SupplejackApi::TopCollectionMetric.where(display_collection: 'Collecty McCollectyface').map(&:metric))
          .not_to include 'page_views'
      end
    end

    context 'with date_range, it only creates top metrics for the given date range' do
      let(:today_and_tomorrow) { Time.now.utc.beginning_of_day..Time.now.utc.tomorrow.end_of_day }

      let!(:metric_one) do
        create(:record_metric, appeared_in_searches: 1,
                               date: Time.now.utc.tomorrow,
                               display_collection: 'Gotta collect them all!')
      end

      let!(:metric_two) do
        create(:record_metric, appeared_in_searches: 2,
                               date: Time.now.utc.tomorrow,
                               display_collection: 'Supplejack LTD')
      end

      let!(:metric_three) do
        create(:record_metric, appeared_in_searches: 3,
                               date: Time.now.utc.tomorrow,
                               display_collection: 'Collecty McCollectyface')
      end

      let!(:metric_group) do
        create_list(:record_metric, 250, date: Time.now.utc.tomorrow,
                                         page_views: 1,
                                         display_collection: 'Laramie')
      end

      let!(:tomorrows_metric_group) do
        create_list(:record_metric, 5, date: Time.now.utc.tomorrow - 1.day,
                                       page_views: 2,
                                       display_collection: 'Laramie')
      end

      before do
        described_class::METRICS.each do |metric|
          create(:record_metric, date: Time.now.utc.tomorrow, metric.to_sym => 1, display_collection: 'Laramie')
        end

        create(:record_metric, date: Time.now.utc.tomorrow, appeared_in_searches: 1, display_collection: 'Laramie')
        create(:record_metric, date: Time.now.utc.tomorrow, appeared_in_searches: 2, display_collection: 'Laramie')
        create(:record_metric, date: Time.now.utc.tomorrow, appeared_in_searches: 3, display_collection: 'Laramie')

        SupplejackApi::TopCollectionMetric.spawn(today_and_tomorrow)
      end

      it 'stamps all processed RecordMetric records :processed_by_top_collection_metrics flag as true' do
        SupplejackApi::RecordMetric.all.each do |record_metric|
          expect(record_metric.processed_by_top_collection_metrics).to be true
        end
      end

      it 'only takes the top 200 records for each metric AND collection' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'page_views',
                                                          display_collection: 'Laramie').results.keys.count).to eq 200
      end

      it 'orders the results from highest to lowest' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.first).to eq 3
      end

      it 'spawns metrics across multiple days' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow - 1.day,
                                                          metric: 'page_views',
                                                          display_collection: 'Laramie').results.keys.count).to eq 5
      end

      it 'sets RecordMetrics :processed_by_top_collection_metrics flag to `true`' do
        [metric_one, metric_two, metric_three].each do |metric|
          expect(metric.reload.processed_by_top_collection_metrics).to be true
        end
      end

      it 'appends new top collection metrics that creep in after the initial run' do
        SupplejackApi::RecordMetric.destroy_all

        create(:record_metric, appeared_in_searches: 1,
                               date: Time.now.utc.tomorrow,
                               record_id: metric_three.record_id,
                               display_collection: 'Laramie')

        create(:record_metric, appeared_in_searches: 1,
                               date: Time.now.utc.tomorrow,
                               display_collection: 'Laramie')

        SupplejackApi::TopCollectionMetric.spawn(today_and_tomorrow)

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.first).to eq 3

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie'))

        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.keys.count).to eq 6
      end

      it 'returns a collection of top collection metrics' do
        described_class.spawn.each do |tcm|
          expect(tcm.class).to eql described_class
        end
      end

      it 'does not include records that have 0 of the requested metric in the results' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.values.uniq)
          .not_to include 0
      end

      it 'only includes records that have valid data' do
        expect(SupplejackApi::TopCollectionMetric.find_by(date: Time.now.utc.tomorrow,
                                                          metric: 'appeared_in_searches',
                                                          display_collection: 'Laramie').results.count).to eq 4
      end

      it 'doesn\'t create top collection metrics when there are no results' do
        expect(SupplejackApi::TopCollectionMetric.where(display_collection: 'Collecty McCollectyface').map(&:metric))
          .not_to include 'page_views'
      end
    end
  end
end
