# frozen_string_literal: true

require 'spec_helper'

describe SupplejackApi::MetricsHelper do
  describe '#start_date_with value' do
    context 'when a date string is passed' do
      it 'returns date object' do
        expect(described_class.start_date_with('2021-02-05')).to eq Date.parse('2021-02-05')
      end
    end

    context 'when no date string is passed' do
      it 'returns date object for yesterday' do
        result = described_class.start_date_with(nil).strftime('%Y-%m-%d %H:%M')

        expect(result).to eq Time.now.utc.yesterday.strftime('%Y-%m-%d %H:%M')
      end
    end
  end

  describe '#end_date_with value' do
    context 'when a date string is passed' do
      it 'returns date object' do
        expect(described_class.end_date_with('2021-02-05')).to eq Date.parse('2021-02-05')
      end
    end

    context 'when no date string is passed' do
      it 'returns date object for today' do
        result = described_class.end_date_with(nil).strftime('%Y-%m-%d %H:%M')

        expect(result).to eq Time.now.utc.to_date.strftime('%Y-%m-%d %H:%M')
      end
    end
  end
end
