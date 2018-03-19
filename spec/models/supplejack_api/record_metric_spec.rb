require 'spec_helper'

RSpec.describe SupplejackApi::RecordMetric do
  describe '#attributes' do
    let(:record_metric) { create(:record_metric, display_collection: 'NDHA', record_id: 1) }

    it 'has a date' do
      expect(record_metric.date).to eq Time.zone.now.utc.to_date
    end

    it 'has a record_id' do
      expect(record_metric.record_id).to eq 1
    end

    it 'has page_views' do
      expect(record_metric.page_views).to eq 0
    end

    it 'has user_set_views' do
      expect(record_metric.user_set_views).to eq 0
    end

    it 'has a content_partner' do
      expect(record_metric.display_collection).to eq 'NDHA'
    end

    it 'has user_story_views' do
      expect(record_metric.user_story_views).to eq 0
    end

    it 'has adeed_to_user_sets' do
      expect(record_metric.added_to_user_sets).to eq 0
    end

    it 'has source_clickthroughs' do
      expect(record_metric.source_clickthroughs).to eq 0
    end

    it 'has appeared_in_searches' do
      expect(record_metric.appeared_in_searches).to eq 0
    end

    it 'has added_to_user_stories' do
      expect(record_metric.added_to_user_stories).to eq 0
    end
  end

  describe '#validations' do
    let(:invalid) { build(:record_metric, record_id: nil) }

    let!(:record_metric)      { create(:record_metric) }
    let(:record_metric_two)   { build(:record_metric, record_id: record_metric.record_id) }
    let(:record_metric_three) { build(:record_metric, date: 1.day.from_now.utc) }

    it 'requires a record_id' do
      invalid.valid?
      expect(invalid.errors[:record_id]).to include 'Record field can\'t be blank.'
    end

    it 'does not create a record metric when one allready exists for given id and date' do
      record_metric_two.valid?
      expect(record_metric_two.errors[:record_id]).to include 'is already taken'
    end

    it 'allows record metrics with the same record id on different days' do
      expect(record_metric_three).to be_valid
    end
  end

  describe '::spawn' do
    let!(:record_metric) { create(:record_metric, record_id: 1, page_views: 1, display_collection: 'NDHA') }

    it 'creates a new RecordMetric when there is not one for the provided day and record_id' do
      expect { SupplejackApi::RecordMetric.spawn(2, { 'appeared_in_searches' => 1 }, 'NDHA') }.to change(SupplejackApi::RecordMetric, :count).by(1)
    end

    it 'does not create a RecordMetric when the provided day and record_id allready exist' do
      expect { SupplejackApi::RecordMetric.spawn(record_metric.record_id, { 'appeared_in_searches' => 1 }, 'NDHA') }.to change(SupplejackApi::RecordMetric, :count).by(0)
    end

    it 'increments an existing Record Metric' do
      SupplejackApi::RecordMetric.spawn(record_metric.record_id, { 'page_views' => 1 }, 'NDHA')
      record_metric.reload
      expect(record_metric.page_views).to eq 2
    end

    it 'increments an existing Record Metric by a given hash of metrics' do
      SupplejackApi::RecordMetric.spawn(record_metric.record_id, { 'page_views' => 7, 'appeared_in_searches' => 6, 'user_set_views' => 10 }, 'NDHA')
      record_metric.reload

      expect(record_metric.page_views).to eq 8
      expect(record_metric.appeared_in_searches).to eq 6
      expect(record_metric.user_set_views).to eq 10
    end
  end
end
