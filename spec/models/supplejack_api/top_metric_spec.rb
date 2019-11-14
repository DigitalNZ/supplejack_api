# frozen_string_literal: true

RSpec.describe SupplejackApi::TopMetric do
  let(:top_metric) { create(:top_metric, results: { 1 => 200, 2 => 150 }, date: Time.now.utc.to_date) }

  describe '#attributes' do
    it 'has a date' do
      expect(top_metric.date).to eq Time.now.utc.to_date
    end

    it 'has a metric' do
      expect(top_metric.metric).to eq 'appeared_in_searches'
    end

    it 'has results' do
      results = { 1 => 200, 2 => 150 }
      expect(top_metric.results).to eq results
    end
  end

  describe '::spawn' do
    context 'no args, it defaults to all dates before today' do
      let!(:metric_one)   { create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.yesterday) }
      let!(:metric_two)   { create(:record_metric, appeared_in_searches: 2, date: Time.now.utc.yesterday) }
      let!(:metric_three) { create(:record_metric, appeared_in_searches: 3, date: Time.now.utc.yesterday) }

      let!(:metric_group) { create_list(:record_metric, 250, date: Time.now.utc.yesterday, page_views: 1) }
      let!(:yesterdays_metric_group) { create_list(:record_metric, 5, date: Time.now.utc.yesterday - 1.day, page_views: 2) }

      before do
        SupplejackApi::TopMetric.spawn
      end

      it 'only takes the top 200 records for each metric' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'page_views').results.keys.count).to eq 200
      end

      it 'orders the results from highest to lowest' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches').results.values.first).to eq 3
      end

      it 'spawns metrics across multiple days' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday - 1.day, metric: 'page_views').results.keys.count).to eq 5
      end

      it 'appends new top metrics that creep in after the initial run' do
        SupplejackApi::RecordMetric.destroy_all

        create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.yesterday, record_id: metric_three.record_id)
        create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.yesterday)

        SupplejackApi::TopMetric.spawn

        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches').results.values.first).to eq 4
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches'))
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches').results.count).to eq 4
      end

      it 'does not add records that have a 0 count into the top results' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches').results.values.uniq).not_to include 0
      end

      it 'only returns the record counts that have important data' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.yesterday, metric: 'appeared_in_searches').results.count).to eq 3
      end

      it 'doesn\'t create records top metrics that have no results' do
        expect(SupplejackApi::TopMetric.all.map(&:metric)).not_to include 'user_set_views'
      end
    end

    context 'with date_range, it creates top metrics for the days within the range' do
      let!(:metric_one)   { create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.tomorrow) }
      let!(:metric_two)   { create(:record_metric, appeared_in_searches: 2, date: Time.now.utc.tomorrow) }
      let!(:metric_three) { create(:record_metric, appeared_in_searches: 3, date: Time.now.utc.tomorrow) }

      let!(:metric_group) { create_list(:record_metric, 250, date: Time.now.utc.tomorrow, page_views: 1) }
      let!(:tomorrows_metric_group) { create_list(:record_metric, 5, date: Time.now.utc.tomorrow - 1.day, page_views: 2) }

      let(:today_and_tomorrow) { Time.now.utc.beginning_of_day..Time.now.utc.tomorrow.end_of_day }

      before do
        SupplejackApi::TopMetric.spawn(today_and_tomorrow)
      end

      it 'only takes the top 200 records for each metric' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'page_views').results.keys.count).to eq 200
      end

      it 'orders the results from highest to lowest' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches').results.values.first).to eq 3
      end

      it 'spawns metrics across multiple days' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow - 1.day, metric: 'page_views').results.keys.count).to eq 5
      end

      it 'appends new top metrics that creep in after the initial run' do
        SupplejackApi::RecordMetric.destroy_all

        create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.tomorrow, record_id: metric_three.record_id)
        create(:record_metric, appeared_in_searches: 1, date: Time.now.utc.tomorrow)

        SupplejackApi::TopMetric.spawn(today_and_tomorrow)

        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches').results.values.first).to eq 4
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches'))
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches').results.count).to eq 4
      end

      it 'does not add records that have a 0 count into the top results' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches').results.values.uniq).not_to include 0
      end

      it 'only returns the record counts that have important data' do
        expect(SupplejackApi::TopMetric.find_by(date: Time.now.utc.tomorrow, metric: 'appeared_in_searches').results.count).to eq 3
      end

      it 'doesn\'t create records top metrics that have no results' do
        expect(SupplejackApi::TopMetric.all.map(&:metric)).not_to include 'user_set_views'
      end
    end
  end
end
