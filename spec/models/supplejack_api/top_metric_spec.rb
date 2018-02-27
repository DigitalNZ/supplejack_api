# frozen_string_literal: true

RSpec.describe SupplejackApi::TopMetric do
  let(:top_metric) { create(:top_metric, results: { 1 => 200, 2 => 150 }) }

  describe '#attributes' do
    it 'has a date' do
      expect(top_metric.date).to eq Time.zone.today
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
    let!(:metric_one)   { create(:record_metric, appeared_in_searches: 1, date: Time.zone.today) }
    let!(:metric_two)   { create(:record_metric, appeared_in_searches: 2, date: Time.zone.today) }
    let!(:metric_three) { create(:record_metric, appeared_in_searches: 3, date: Time.zone.today) }

    let!(:metric_group) { create_list(:record_metric, 250, date: Time.zone.today, page_views: 1) }
    let!(:yesterdays_metric_group) { create_list(:record_metric, 5, date: Time.zone.yesterday, page_views: 2) }

    before do
      SupplejackApi::TopMetric.spawn
    end

    it 'creates TopMetrics for each metric' do
      expect(SupplejackApi::TopMetric.all.map(&:metric).uniq.sort).to eq ['added_to_user_sets', 'added_to_user_stories', 'appeared_in_searches', 'page_views', 'source_clickthroughs', 'user_set_views', 'user_story_views']
    end

    it 'only takes the top 200 records for each metric' do
      expect(SupplejackApi::TopMetric.find_by(date: Time.zone.today, metric: 'page_views').results.keys.count).to eq 200
    end

    it 'orders the results from highest to lowest' do
      binding.pry
      expect(SupplejackApi::TopMetric.find_by(date: Time.zone.today, metric: 'page_views').results.values.first).to eq 1
    end

    it 'spawns metrics across multiple days' do
      expect(SupplejackApi::TopMetric.find_by(date: Time.zone.yesterday, metric: 'page_views').results.keys.count).to eq 5
    end
  end
end
