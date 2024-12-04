# frozen_string_literal: true

require 'spec_helper'

describe SupplejackApi::DateHelper do
  describe '#parse_as_solr_date_range' do
    it 'correctly parses date range' do
      expect(described_class.parse_as_solr_date_range('2019/2020')).to eq '[2019-01-01 TO 2020-12-31]'
    end

    it 'returns nil for invalid range' do
      expect(described_class.parse_as_solr_date_range('/')).to eq nil
    end

    it 'correctly parses single year as a range' do
      expect(described_class.parse_as_solr_date_range('1985')).to eq '[1985-01-01 TO 1985-12-31]'
    end

    it 'correctly parses single year month date as a range' do
      expect(described_class.parse_as_solr_date_range('1985-04')).to eq '[1985-04-01 TO 1985-04-30]'
    end

    it 'correctly parses single year month day date' do
      expect(described_class.parse_as_solr_date_range('1985-04-01')).to eq '1985-04-01'
    end

    it 'returns nil for invalid date' do
      expect(described_class.parse_as_solr_date_range('q3rtqqa-04')).to eq nil
    end

    context 'when date is a DateTime' do
      it 'formats the datetime using zulu time (which solr requires)' do
        expect(described_class.parse_as_solr_date_range('1851-01-01T00:00:00Z')).to eq '1851-01-01T00:00:00Z'
      end
    end
  end

  describe '#solr_format' do
    it 'formats the datetime using zulu time (which solr requires)' do
      expect(described_class.solr_format(DateTime.new('1851'.to_i))).to eq '1851-01-01T00:00:00Z'
    end

    it 'formats the date to ISO8601' do
      expect(described_class.solr_format(Date.new('1851'.to_i))).to eq '1851-01-01'
    end
  end

  describe '#parse_as_range' do
    it 'returns nil for invalid EDTF date ranges' do
      expect(described_class.parse_as_range('invalid')).to be_nil
    end

    it 'formats a simple date range' do
      range = '1900/1901'
      expected = '[1900-01-01 TO 1901-12-31]'

      expect(described_class.parse_as_range(range)).to eq(expected)
    end

    it 'formats a range with specific months' do
      range = '1900-06/1900-08'
      expected = '[1900-06-01 TO 1900-08-31]'

      expect(described_class.parse_as_range(range)).to eq(expected)
    end

    it 'formats a range with specific days' do
      range = '1900-06-01/1900-06-15'
      expected = '[1900-06-01 TO 1900-06-15]'

      expect(described_class.parse_as_range(range)).to eq(expected)
    end
  end
end
