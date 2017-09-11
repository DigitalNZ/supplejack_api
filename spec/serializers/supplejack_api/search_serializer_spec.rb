# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordSearchSerializer do
    let!(:record) { FactoryGirl.create(:record) }
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
  end
end
