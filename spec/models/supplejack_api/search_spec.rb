

require 'spec_helper'

module SupplejackApi
  describe Search do
  	before {
      @search = Search.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      allow(Search).to receive(:role_collection_restrictions) { [] }
    }

    describe '#initialize' do
      it 'sets the options' do
        expect(@search).to respond_to :options
      end
    end

  	describe '#facet_list' do
  		before {
        # Record Search is used here rather than Search
        # this method uses a RecordSearchSchema within `Search#schema_class`
        # Essentially, without RecordSearch the test breaks
        @search = RecordSearch.new
        allow(@search).to receive(:model_class) { Record }
      }

      it 'should return a array of facets' do
        @search.options[:facets] = 'name, address'
        expect(@search.facet_list).to eq [:name, :address]
      end

      it 'should discard any fields not configured as facets' do
        @search.options[:facets] = 'name, address, other_facet'
        expect(@search.facet_list).to eq [:name, :address]
      end
    end

    describe '#field_list' do
    	before {
        # Record Search is used here rather than Search
        # this method uses a RecordSearchSchema within `Search#schema_class`
        # Essentially, without RecordSearch the test breaks
        @search = RecordSearch.new
        allow(@search).to receive(:schema_class) { RecordSchema }
      }

      it 'should return a array of fields' do
        @search.options[:fields] = 'name, address'
        expect(@search.field_list).to eq [:name, :address]
      end

      it 'should only return valid fields' do
        @search.options[:fields] = 'name, something_else'
        expect(@search.field_list).to eq [:name]
      end
    end

    describe '#group_list' do
    	before {
        # Record Search is used here rather than Search
        # this method uses a RecordSearchSchema within `Search#schema_class`
        # Essentially, without RecordSearch the test breaks
        @search = RecordSearch.new
        allow(@search).to receive(:model_class) { Record }
      }

	    it 'gets the groups from the fields list' do
	      @search.options[:fields] = "content_partner, core"
	      expect(@search.group_list).to eq [:core]
	    end
	  end

	  describe '#query_fields' do
      it 'returns nil when no query fields were specified' do
        @search = Search.new
        expect(@search.query_fields).to be_nil
      end

      it 'returns the query fields from the params' do
        @search = Search.new(query_fields: [:collection])
        expect(@search.query_fields).to eq([:collection])
      end

      it 'supports the query_fields as comma separated string' do
        @search = Search.new(query_fields: 'collection, creator, publisher')
        expect(@search.query_fields).to eq([:collection, :creator, :publisher])
      end

      it 'converts an array of strings to symbols' do
        @search = Search.new(query_fields: ['collection','creator'])
        expect(@search.query_fields).to eq([:collection, :creator])
      end

      it 'returns nil when query_fields is an empty string' do
        @search = Search.new(query_fields: '')
        expect(@search.query_fields).to be_nil
      end

      it 'returns nil when query_fields is an empty array' do
        @search = Search.new(query_fields: [])
        expect(@search.query_fields).to be_nil
      end
    end

    describe '#extract_range' do
      it 'extracts the dates from [1900 TO 2000] and return a range' do
        expect(@search.extract_range('[1900 TO 2000]')).to eq(1900..2000)
      end

      it 'doesn\'t match non numbers' do
        expect(@search.extract_range('[asdasd TO asdads]')).to eq '[asdasd TO asdads]'
      end

      it 'returns the current value if is not a range and converts it to int' do
        expect(@search.extract_range('1900')).to eq 1900
      end
    end

     describe '#to_proper_value' do
      it 'returns false for "false" string' do
        expect(@search.to_proper_value('active?', 'false')).to be_falsey
      end

      it 'returns true for "true" string' do
        expect(@search.to_proper_value('active?', 'true')).to be_truthy
      end

      it 'returns nil if is a "nil" string' do
        expect(@search.to_proper_value('active?', 'nil')).to be_nil
      end

      it 'returns nil if is a "null" string' do
        expect(@search.to_proper_value('active?', 'null')).to be_nil
      end

      it 'returns the value unchanged' do
        expect(@search.to_proper_value('label', 'Black')).to eq('Black')
      end

      it 'should strip any white space' do
        expect(@search.to_proper_value('label', ' Black Label ')).to eq('Black Label')
      end
    end

    describe '#text' do
      it 'downcases the text string' do
        expect(Search.new(text: 'McDowall').text).to eq 'mcdowall'
      end

      ['AND', 'OR', 'NOT'].each do |operator|
        it "downcases everything except the #{operator} operators" do
          expect(Search.new(text: "McDowall #{operator} Dogs").text).to eq "mcdowall #{operator} dogs"
        end
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

      it 'sets warning if page vale is greater than 10000' do
        @search.options[:page] = 100_001
        @search.valid?

        expect(@search.errors).to include 'The page parameter can not exceed 100000'
      end

      it 'sets warning if per_page vale is greater than 100' do
        @search.options[:per_page] = 101
        @search.valid?

        expect(@search.errors).to include 'The per_page parameter can not exceed 100'
      end

      it 'sets warning if facets_per_page vale is greater than 350' do
        @search.options[:facets_per_page] = 351
        @search.valid?

        expect(@search.errors).to include 'The facets_per_page parameter can not exceed 350'
      end

      it 'sets warning if facets_page vale is greater than 5000' do
        @search.options[:facets_page] = 5001
        @search.valid?

        expect(@search.errors).to include 'The facets_page parameter can not exceed 5000'
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
        @search.options[:debug] = 'true'
        allow(@search).to receive(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        expect(@search.solr_request_params).to eq({:param1 => 1})
      end

      it "doesn't set the solr request parameters" do
        allow(@search).to receive(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        expect(@search.solr_request_params).to be_nil
      end

      it 'returns a empty hash when solr request fails' do
        @search.options[:debug] = 'true'
        allow(@search).to receive(:execute_solr_search) { {} }
        expect(@search.solr_search_object).to eq({})
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
