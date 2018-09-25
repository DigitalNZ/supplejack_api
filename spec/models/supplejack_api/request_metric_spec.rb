require 'spec_helper'

RSpec.describe SupplejackApi::RequestMetric do
  describe '#attributes' do
    let(:request_metric) { create(:request_metric) }

    it 'has a date' do
      expect(request_metric.date).not_to be nil
    end

    it 'has records' do
      expect(request_metric.records).to eq [
        { record_id: 1001, display_collection: 'TAPHUI' },
        { record_id: 289, display_collection: 'Papers Past' },
        { record_id: 289, display_collection: 'Papers Past' },
        { record_id: 30, display_collection: 'TAPHUI' },
        { record_id: 411, display_collection: 'National Library of New Zealand' }
      ]
    end

    it 'has a metric' do
      expect(request_metric.metric).to eq 'appeared_in_searches'
    end
  end

  describe '#summarize' do

    let!(:appeared_in_searches_yesterday) { create_list(:request_metric, 5, date: 1.day.ago.utc) }
    let!(:user_set_views_yesterday) { create_list(:request_metric, 5, metric: 'user_set_views', date: 1.day.ago.utc) }
    let!(:source_clickthroughs_yesterday) { create_list(:request_metric, 5, metric: 'source_clickthroughs', date: 1.day.ago.utc) }

    let!(:appeared_in_searches_today) { create_list(:request_metric, 5) }
    let!(:user_set_views_today) { create_list(:request_metric, 5, metric: 'user_set_views') }
    let!(:source_clickthroughs_today) { create_list(:request_metric, 5, metric: 'source_clickthroughs') }

    it 'summarizes request metrics and saves them into Mongo' do
      SupplejackApi::RequestMetric.summarize

      expect(SupplejackApi::RecordMetric.count).to eq 8

      yesterday_summed_1001 = SupplejackApi::RecordMetric.find_by(record_id: 1001, date: 1.day.ago.utc)
      yesterday_summed_289 = SupplejackApi::RecordMetric.find_by(record_id: 289, date: 1.day.ago.utc)
      yesterday_summed_30 = SupplejackApi::RecordMetric.find_by(record_id: 30, date: 1.day.ago.utc)
      yesterday_summed_411 = SupplejackApi::RecordMetric.find_by(record_id: 411, date: 1.day.ago.utc)

      today_summed_1001 = SupplejackApi::RecordMetric.find_by(record_id: 1001, date: Time.zone.now)
      today_summed_289 = SupplejackApi::RecordMetric.find_by(record_id: 289, date: Time.zone.now)
      today_summed_30 = SupplejackApi::RecordMetric.find_by(record_id: 30, date: Time.zone.now)
      today_summed_411 = SupplejackApi::RecordMetric.find_by(record_id: 411, date: Time.zone.now)

      expect(yesterday_summed_1001.appeared_in_searches).to eq 5
      expect(yesterday_summed_289.appeared_in_searches).to eq 10
      expect(yesterday_summed_30.appeared_in_searches).to eq 5
      expect(yesterday_summed_30.appeared_in_searches).to eq 5

      expect(yesterday_summed_1001.user_set_views).to eq 5
      expect(yesterday_summed_289.user_set_views).to eq 10
      expect(yesterday_summed_30.user_set_views).to eq 5
      expect(yesterday_summed_30.user_set_views).to eq 5

      expect(yesterday_summed_1001.source_clickthroughs).to eq 5
      expect(yesterday_summed_289.source_clickthroughs).to eq 10
      expect(yesterday_summed_30.source_clickthroughs).to eq 5
      expect(yesterday_summed_30.source_clickthroughs).to eq 5

      expect(today_summed_1001.appeared_in_searches).to eq 5
      expect(today_summed_289.appeared_in_searches).to eq 10
      expect(today_summed_30.appeared_in_searches).to eq 5
      expect(today_summed_30.appeared_in_searches).to eq 5

      expect(today_summed_1001.user_set_views).to eq 5
      expect(today_summed_289.user_set_views).to eq 10
      expect(today_summed_30.user_set_views).to eq 5
      expect(today_summed_30.user_set_views).to eq 5

      expect(today_summed_1001.source_clickthroughs).to eq 5
      expect(today_summed_289.source_clickthroughs).to eq 10
      expect(today_summed_30.source_clickthroughs).to eq 5
      expect(today_summed_30.source_clickthroughs).to eq 5

      expect(SupplejackApi::RequestMetric.count).to eq 0
    end
  end
end
