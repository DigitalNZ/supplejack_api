# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SearchSerializer do
    let!(:record) { create(:record) }
    let(:search)  { SupplejackApi::RecordSearch.new }
    let(:serialized_search) { described_class.new(search).as_json }

    it 'has :result_count' do
      expect(serialized_search[:result_count]).to eq search.total
    end

    it 'has :results' do
      expect(serialized_search).to have_key :results
    end

    it 'has :per_page' do
      expect(serialized_search[:per_page]).to eq search.per_page
    end

    it 'has :page' do
      expect(serialized_search[:page]).to eq search.page
    end

    it 'has :request_url' do
      expect(serialized_search[:request_url]).to eq search.request_url
    end

    it 'has facets' do
      expect(serialized_search).to have_key :facets
    end

    it 'returns facets formatted for JSON when the request_format is JSON' do
      expect(serialized_search[:facets]).to be_a(Hash)
    end

    describe '#xml?' do
      let(:xml_serializer) { described_class.new(search, { request_format: 'xml' }) }

      it 'returns true when the serializer has been initialized for XML' do
        expect(xml_serializer.xml?).to eq true
      end

      it 'returns facets as an array' do
        expect(xml_serializer.as_json[:facets]).to be_a(Array)
      end
    end
  end
end
