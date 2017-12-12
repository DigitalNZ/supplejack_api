# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe SearchSerializer do
    let!(:record) { FactoryBot.create(:record) }
    let(:search)  { SupplejackApi::RecordSearch.new }
    let(:serialized_search) { described_class.new(search).as_json }

    it 'renders the :result_count' do
      expect(serialized_search).to have_key :result_count
    end

    it 'renders the :results' do
      expect(serialized_search).to have_key :results
    end

    it 'renders :per_page' do
      expect(serialized_search).to have_key :per_page
    end

    it 'renders :page' do
      expect(serialized_search).to have_key :page
    end

    it 'renders :request_url' do
      expect(serialized_search).to have_key :request_url
    end

    it 'renders the facets' do
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
