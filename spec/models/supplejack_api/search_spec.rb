# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe Search do
    before do
      @search = RecordSearch.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      allow(Search).to receive(:role_collection_restrictions) { [] }
    end

    describe '#initialize' do
      it 'sets the options' do
        expect(RecordSearch.new).to respond_to :options
      end

      it 'reverse_merges default options without replacing requested options' do
        expect(RecordSearch.new(fields: 'title').options.fields).to eq [:title]
      end

      it 'uses sensible defaults when no options are provided' do
        search = RecordSearch.new
        expect(search.options.facets).to eq []
        expect(search.options.facet_pivots).to eq []
        expect(search.options.and_condition).to eq({})
        expect(search.options.or_condition).to eq({})
        expect(search.options.without).to eq({})
        expect(search.options.page).to eq 1
        expect(search.options.per_page).to eq 20
        expect(search.options.record_type).to eq 0
        expect(search.options.facets_per_page).to eq 10
        expect(search.options.facets_page).to eq 1
        expect(search.options.sort).to eq nil
        expect(search.options.direction).to eq 'desc'
        expect(search.options.exclude_filters_from_facets).to eq false
        expect(search.options.fields).to eq []
        expect(search.options.group_list).to eq [:default]
        expect(search.options.facet_query).to eq({})
        expect(search.options.debug).to eq false
      end
    end

    describe '#facet_list' do
      it 'should return an array of facets' do
        expect(RecordSearch.new(facets: 'name, address').options.facets).to eq %i[name address]
      end

      it 'should discard any fields not configured as facets' do
        expect(RecordSearch.new(facets: 'name, address, other_facet').options.facets).to eq %i[name address]
      end

      it 'should return string versions of integer facets' do
        expect(RecordSearch.new(facets: 'age').options.facets).to eq [:age_str]
      end

      it 'should return string versions of date facets' do
        expect(RecordSearch.new(facets: 'birth_date').options.facets).to eq [:birth_date_str]
      end
    end

    describe '#facet_pivot_list' do
      it 'should return an empty string when an empty string is provided' do
        expect(RecordSearch.new(facet_pivots: '').options.facet_pivots).to eq []
      end

      it 'should return a array of facets' do
        search = RecordSearch.new(facet_pivots: 'category,description')
        expect(search.options.facet_pivots).to eq 'category_sm,description_s'
      end

      it 'should discard any fields not configured as facets' do
        expect(RecordSearch.new(facet_pivots: 'postcode,description').options.facet_pivots).to eq 'description_s'
      end
    end

    describe '#field_list' do
      it 'should return a array of fields' do
        expect(RecordSearch.new(fields: 'name, address').options.fields).to eq %i[name address]
      end

      it 'should only return valid fields' do
        expect(RecordSearch.new(fields: 'name, something_else').options.fields).to eq [:name]
      end
    end

    describe '#group_list' do
      it 'gets the groups from the fields list' do
        expect(RecordSearch.new(fields: 'content_partner, core').options.group_list).to eq [:core]
      end
    end

    describe 'group_params' do
      it 'groups records by the provided parameters' do
        search = RecordSearch.new(group_by: 'group_index', group_order_by: 'version_index', group_sort: 'asc')

        expect(search.options.group_by).to eq 'group_index'
        expect(search.options.group_order_by).to eq 'version_index'
        expect(search.options.group_sort).to eq 'asc'
      end
    end

    describe '#query_fields' do
      it 'returns nil when no query fields were specified' do
        expect(RecordSearch.new.options.query_fields).to eq []
      end

      it 'returns the query fields from the params' do
        search = RecordSearch.new(query_fields: [:display_collection])
        expect(search.options.query_fields).to eq([:display_collection])
      end

      it 'supports the query_fields as comma separated string' do
        search = RecordSearch.new(query_fields: 'display_collection, creator, nz_citizen')
        expect(search.options.query_fields).to eq(%i[display_collection creator nz_citizen])
      end

      it 'converts an array of strings to symbols' do
        search = RecordSearch.new(query_fields: %w[display_collection creator])
        expect(search.options.query_fields).to eq(%i[display_collection creator])
      end

      it 'returns an empty array when query_fields is an empty string' do
        search = RecordSearch.new(query_fields: '')
        expect(search.options.query_fields).to eq []
      end

      it 'returns an empty array when query_fields is an empty array' do
        search = RecordSearch.new(query_fields: [])
        expect(search.options.query_fields).to eq []
      end
    end

    describe '#text' do
      it 'downcases the text string' do
        expect(RecordSearch.new(text: 'McDowall').options.text).to eq 'mcdowall'
      end

      %w[AND OR NOT].each do |operator|
        it "downcases everything except the #{operator} operators" do
          expect(RecordSearch.new(text: "McDowall #{operator} Dogs").options.text).to eq "mcdowall #{operator} dogs"
        end
      end
    end

    describe 'sort by date' do
      it 'should be successful' do
        search = RecordSearch.new(sort: 'date')
        expect { search.results }.to_not raise_error(ArgumentError)
      end
    end

    describe 'sort by random' do
      it 'should include the correct search sort' do
        search = RecordSearch.new(sort: 'random')

        expect(search.search_builder.inspect.include?('sort: "random desc"')).to eq true
      end
    end

    describe '#valid?' do
      before { allow(@search).to receive(:solr_search_object).and_return(true) }

      it 'returns true if no errors' do
        allow(@search).to receive(:errors).and_return([])
        expect(@search.valid?).to be true
      end

      it 'returns false if errors exist' do
        allow(@search).to receive(:errors).and_return(['some error'])
        expect(@search.valid?).to be false
      end

      it 'returns false when search bilder raises error' do
        allow(@search).to receive(:solr_search_object).and_raise(Sunspot::UnrecognizedFieldError)
        expect(@search.valid?).to be false
      end

      it 'sets warning if page vale is greater than 100' do
        search = RecordSearch.new(page: 101)
        search.valid?

        expect(search.errors).to
          include 'The page parameter for anonymous users (without an API key) can not exceed 100'
      end

      it 'sets warning if per_page vale is greater than 100' do
        search = RecordSearch.new(per_page: 101)
        search.valid?

        expect(search.errors).to include 'The per_page parameter can not exceed 100'
      end

      it 'sets warning if facets_per_page vale is greater than 350' do
        search = RecordSearch.new(facets_per_page: 351)
        search.valid?

        expect(search.errors).to include 'The facets_per_page parameter can not exceed 350'
      end

      it 'sets warning if facets_page vale is greater than 5000' do
        search = RecordSearch.new(facets_page: 5001)
        search.valid?

        expect(search.errors).to include 'The facets_page parameter can not exceed 5000'
      end
    end

    describe '#solr_search_object' do
      it 'memoizes the solr search object' do
        sunspot_mock = double(:solr).as_null_object
        expect(@search).to receive(:execute_solr_search).once.and_return(sunspot_mock)
        @search.solr_search_object
        expect(@search.solr_search_object).to eq(sunspot_mock)
      end

      it 'sets the solr request parameters when debug=true' do
        search = RecordSearch.new(debug: 'true')
        allow(search).to receive(:execute_solr_search) {
          double(:solr_request, query: double(:query, to_params: { param1: 1 }))
        }

        search.solr_search_object
        expect(search.solr_request_params).to eq({ param1: 1 })
      end

      it "doesn't set the solr request parameters" do
        allow(@search).to receive(:execute_solr_search) {
          double(:solr_request, query: double(:query, to_params: { param1: 1 }))
        }

        @search.solr_search_object
        expect(@search.solr_request_params).to be_nil
      end

      it 'returns a empty hash when solr request fails' do
        search = RecordSearch.new(debug: 'true')
        allow(search).to receive(:execute_solr_search) { {} }
        expect(search.solr_search_object).to eq({})
      end
    end

    describe '#method_missing' do
      it 'delegates any missing method to the solr_search_object' do
        sso = double(:sso, something_missing: [], hits: [])
        allow(@search).to receive(:solr_search_object).and_return(sso)
        expect(sso).to receive(:something_missing)
        @search.something_missing
      end

      it 'returns nil when solr request failed' do
        allow(@search).to receive(:solr_search_object).and_return({})
        expect(@search.something_missing).to be_nil
      end
    end
  end
end
