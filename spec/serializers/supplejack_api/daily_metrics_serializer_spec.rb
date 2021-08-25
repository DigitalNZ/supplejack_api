# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe DailyMetricsSerializer do
    let(:metric) { create(:daily_metrics, date: Time.now.utc.to_date, total_public_sets: 101) }
    let(:response) { described_class.new(metric).as_json }

    it 'has day' do
      expect(response[:day]).to eq metric.date
    end

    it 'has total_public_sets' do
      expect(response[:total_public_sets]).to eq metric.total_public_sets
    end
  end
end
