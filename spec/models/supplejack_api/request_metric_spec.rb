# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::RequestMetric do
  describe '#attributes' do
    let(:request_metric) { create(:request_metric) }

    it 'has a date' do
      expect(request_metric.date).not_to be nil
    end

    it 'has records' do
      expect(request_metric.records).to eq [
        { 'record_id' => 1001, 'display_collection' => 'TAPHUI' },
        { 'record_id' => 289, 'display_collection' => 'Papers Past' },
        { 'record_id' => 289, 'display_collection' => 'Papers Past' },
        { 'record_id' => 30, 'display_collection' => 'TAPHUI' },
        { 'record_id' => 411, 'display_collection' => 'National Library of New Zealand' }
      ]
    end

    it 'has a metric' do
      expect(request_metric.metric).to eq 'appeared_in_searches'
    end
  end

  describe 'validations' do
    it 'must have an array in records' do
      rm = create(:request_metric)
      rm.records = []
      rm.save
      expect(rm.errors.full_messages).to eq ["Records Records field can't be blank."]
    end

    it 'must have a metric set' do
      rm = create(:request_metric)
      rm.metric = nil
      rm.save
      expect(rm.errors.full_messages).to eq ["Metric Metric field can't be blank."]
    end

    it 'must not have a record with a nil record_id' do
      rm = create(:request_metric)
      rm.records = [{ record_id: nil, display_collection: 'test' }]
      rm.save
      expect(rm.errors.full_messages).to eq ['Records must contain each a record_id and a display_collection']
    end

    it 'must not have a record with a nil display_collection' do
      rm = create(:request_metric)
      rm.records = [{ record_id: 1, display_collection: nil }]
      rm.save
      expect(rm.errors.full_messages).to eq ['Records must contain each a record_id and a display_collection']
    end
  end

  describe '#summarize' do
    let!(:appeared_in_searches_yesterday) { create_list(:request_metric, 5, date: 1.day.ago.utc.to_date) }
    let!(:user_set_views_yesterday) do
      create_list(:request_metric, 5, metric: 'user_set_views', date: 1.day.ago.utc.to_date)
    end

    let!(:source_clickthroughs_yesterday) do
      create_list(:request_metric, 5, metric: 'source_clickthroughs', date: 1.day.ago.utc.to_date)
    end

    let!(:appeared_in_searches_today) { create_list(:request_metric, 5) }
    let!(:user_set_views_today) { create_list(:request_metric, 5, metric: 'user_set_views') }
    let!(:source_clickthroughs_today) { create_list(:request_metric, 5, metric: 'source_clickthroughs') }

    it 'summarizes request metrics and saves them into Mongo' do
      SupplejackApi::RequestMetric.summarize

      expect(SupplejackApi::RecordMetric.count).to eq 8

      yesterday_summed1001 = SupplejackApi::RecordMetric.find_by(record_id: 1001, date: 1.day.ago.utc.to_date)
      yesterday_summed289 = SupplejackApi::RecordMetric.find_by(record_id: 289, date: 1.day.ago.utc.to_date)
      yesterday_summed30 = SupplejackApi::RecordMetric.find_by(record_id: 30, date: 1.day.ago.utc.to_date)

      today_summed1001 = SupplejackApi::RecordMetric.find_by(record_id: 1001, date: Time.now.utc.to_date)
      today_summed289 = SupplejackApi::RecordMetric.find_by(record_id: 289, date: Time.now.utc.to_date)
      today_summed30 = SupplejackApi::RecordMetric.find_by(record_id: 30, date: Time.now.utc.to_date)

      expect(yesterday_summed1001.appeared_in_searches).to eq 5
      expect(yesterday_summed289.appeared_in_searches).to eq 10
      expect(yesterday_summed30.appeared_in_searches).to eq 5
      expect(yesterday_summed30.appeared_in_searches).to eq 5

      expect(yesterday_summed1001.user_set_views).to eq 5
      expect(yesterday_summed289.user_set_views).to eq 10
      expect(yesterday_summed30.user_set_views).to eq 5
      expect(yesterday_summed30.user_set_views).to eq 5

      expect(yesterday_summed1001.source_clickthroughs).to eq 5
      expect(yesterday_summed289.source_clickthroughs).to eq 10
      expect(yesterday_summed30.source_clickthroughs).to eq 5
      expect(yesterday_summed30.source_clickthroughs).to eq 5

      expect(today_summed1001.appeared_in_searches).to eq 5
      expect(today_summed289.appeared_in_searches).to eq 10
      expect(today_summed30.appeared_in_searches).to eq 5
      expect(today_summed30.appeared_in_searches).to eq 5

      expect(today_summed1001.user_set_views).to eq 5
      expect(today_summed289.user_set_views).to eq 10
      expect(today_summed30.user_set_views).to eq 5
      expect(today_summed30.user_set_views).to eq 5

      expect(today_summed1001.source_clickthroughs).to eq 5
      expect(today_summed289.source_clickthroughs).to eq 10
      expect(today_summed30.source_clickthroughs).to eq 5
      expect(today_summed30.source_clickthroughs).to eq 5

      expect(SupplejackApi::RequestMetric.count).to eq 0
    end
  end
end
