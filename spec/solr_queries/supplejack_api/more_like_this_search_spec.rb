# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe MoreLikeThisSearch do
    let(:record) { create(:record) }

    before do
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      # allow(MoreLikeThisSearch).to receive(:role_collection_restrictions) { [] }
    end

    describe '#initialize' do
      it 'sets the options' do
        expect(MoreLikeThisSearch.new(record, :anonymous, {})).to respond_to :options
      end

      it 'reverse_merges default options without replacing requested options' do
        expect(MoreLikeThisSearch.new(record, :anonymous, fields: 'title').options.fields).to eq [:title]
      end

      it 'uses sensible defaults when no options are provided' do
        search = MoreLikeThisSearch.new(record, :anonymous, {})
        expect(search.options.and_condition).to eq({})
        expect(search.options.or_condition).to eq({})
        expect(search.options.without).to eq({})
        expect(search.options.page).to eq 1
        expect(search.options.per_page).to eq 5
        expect(search.options.record_type).to eq 0
        expect(search.options.sort).to eq nil
        expect(search.options.direction).to eq 'desc'
        expect(search.options.fields).to eq []
        expect(search.options.group_list).to eq [:default]
        expect(search.options.debug).to eq false
      end
    end

    describe '#field' do
      it 'should return a array of fields' do
        expect(MoreLikeThisSearch.new(record, :anonymous, fields: 'name, address').options.fields)
          .to eq %i[name address]
      end

      it 'should only return valid fields' do
        expect(MoreLikeThisSearch.new(record, :anonymous, fields: 'name, something_else').options.fields).to eq [:name]
      end
    end

    describe '#group_list' do
      it 'gets the groups from the fields list' do
        expect(MoreLikeThisSearch.new(record, :anonymous,
                                      fields: 'content_partner, core').options.group_list).to eq [:core]
      end
    end

    describe '#query_fields' do
      it 'returns nil when no query fields were specified' do
        expect(MoreLikeThisSearch.new(record, :anonymous, {}).options.query_fields).to eq []
      end

      it 'returns the query fields from the params' do
        search = MoreLikeThisSearch.new(record, :anonymous, query_fields: [:display_collection])
        expect(search.options.query_fields).to eq([:display_collection])
      end

      it 'supports the query_fields as comma separated string' do
        search = MoreLikeThisSearch.new(record, :anonymous, query_fields: 'display_collection, creator, nz_citizen')
        expect(search.options.query_fields).to eq(%i[display_collection creator nz_citizen])
      end

      it 'converts an array of strings to symbols' do
        search = MoreLikeThisSearch.new(record, :anonymous, query_fields: %w[display_collection creator])
        expect(search.options.query_fields).to eq(%i[display_collection creator])
      end

      it 'returns an empty array when query_fields is an empty string' do
        search = MoreLikeThisSearch.new(record, :anonymous, query_fields: '')
        expect(search.options.query_fields).to eq []
      end

      it 'returns an empty array when query_fields is an empty array' do
        search = MoreLikeThisSearch.new(record, :anonymous, query_fields: [])
        expect(search.options.query_fields).to eq []
      end
    end

    describe 'sort by date' do
      it 'should be successful' do
        search = MoreLikeThisSearch.new(record, :anonymous, sort: 'date')
        expect { search.results }.to_not raise_error(ArgumentError)
      end
    end

    describe '#valid?' do
      it 'returns true if no errors' do
        expect(MoreLikeThisSearch.new(record, :anonymous, {}).valid?).to be true
      end

      it 'sets error if page value is greater than 100_000' do
        search = MoreLikeThisSearch.new(record, :anonymous, page: 100_001)
        expect(search.errors).to include 'The page parameter can not exceed 100000'
      end

      it 'sets warning if per_page vale is greater than 100' do
        search = MoreLikeThisSearch.new(record, :anonymous, per_page: 101)
        expect(search.errors).to include 'The per_page parameter can not exceed 100'
      end
    end
  end
end
