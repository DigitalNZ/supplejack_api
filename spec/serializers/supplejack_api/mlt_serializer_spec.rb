# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe MltSerializer do
    let(:record) { create(:record) }
    let(:search) { SupplejackApi::MoreLikeThisSearch.new(record, :anonymous, {}) }
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
  end
end
