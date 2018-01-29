require 'spec_helper'

RSpec.describe SupplejackApi::RecordMetric do
  let(:record_metric) { create(:record_metric) }

  describe '#attributes' do
    it 'has a date' do
      expect(record_metric.date).to eq Date.today
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

    it 'has adeed_to_user_sets' do
      expect(record_metric.added_to_user_sets).to eq 0
    end

    it 'has source_clickthroughs' do
      expect(record_metric.source_clickthroughs).to eq 0
    end

    it 'has appeared_in_searches' do
      expect(record_metric.appeared_in_searches).to eq 0
    end
  end

  describe '#validations' do
    it 'prevents you from creating a RecordMetric that has the same record_id and date' do

    end
  end
end
