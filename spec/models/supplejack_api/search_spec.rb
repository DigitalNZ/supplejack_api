# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe Search do
  	before {
      @search = Search.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      Search.stub(:role_collection_restrictions) { [] }
    }

  	describe '#facet_list' do
  		before {
        @search = RecordSearch.new
        @search.stub(:model_class) { Record }
      }

      it 'should return a array of facets' do
        @search.options[:facets] = 'name, address'
        @search.facet_list.should eq [:name, :address]
      end

      it 'should discard any fields not configured as facets' do
        @search.options[:facets] = 'name, address, other_facet'
        @search.facet_list.should eq [:name, :address]
      end
    end

    describe '#field_list' do
    	before {
        @search = RecordSearch.new
        @search.stub(:schema_class) { RecordSchema }
      }

      it 'should return a array of fields' do
        @search.options[:fields] = 'name, address'
        @search.field_list.should eq [:name, :address]
      end

      it 'should only return valid fields' do
        @search.options[:fields] = 'name, something_else'
        @search.field_list.should eq [:name]
      end
    end

    describe '#group_list' do
    	before {
        @search = RecordSearch.new
        @search.stub(:model_class) { Record }
      }

	    it 'gets the groups from the fields list' do
	      @search.options[:fields] = "content_partner, core"
	      @search.group_list.should eq [:core]
	    end
	  end

	  describe '#query_fields' do
      it 'returns nil when no query fields were specified' do
        @search = Search.new
        @search.query_fields.should be_nil
      end

      it 'returns the query fields from the params' do
        @search = Search.new(query_fields: [:collection])
        @search.query_fields.should eq([:collection])
      end

      it 'supports the query_fields as comma separated string' do
        @search = Search.new(query_fields: 'collection, creator, publisher')
        @search.query_fields.should eq([:collection, :creator, :publisher])
      end

      it 'converts an array of strings to symbols' do
        @search = Search.new(query_fields: ['collection','creator'])
        @search.query_fields.should eq([:collection, :creator])
      end

      it 'returns nil when query_fields is an empty string' do
        @search = Search.new(query_fields: '')
        @search.query_fields.should be_nil
      end

      it 'returns nil when query_fields is an empty array' do
        @search = Search.new(query_fields: [])
        @search.query_fields.should be_nil
      end
    end

    describe '#extract_range' do
      it 'extracts the dates from [1900 TO 2000] and return a range' do
        @search.extract_range('[1900 TO 2000]').should eq(1900..2000)
      end

      it 'doesn\'t match non numbers' do
        @search.extract_range('[asdasd TO asdads]').should eq '[asdasd TO asdads]'
      end

      it 'returns the current value if is not a range and converts it to int' do
        @search.extract_range('1900').should eq 1900
      end
    end

     describe '#to_proper_value' do
      it 'returns false for "false" string' do
        @search.to_proper_value('active?', 'false').should be_falsey
      end

      it 'returns true for "true" string' do
        @search.to_proper_value('active?', 'true').should be_truthy
      end

      it 'returns nil if is a "nil" string' do
        @search.to_proper_value('active?', 'nil').should be_nil
      end

      it 'returns nil if is a "null" string' do
        @search.to_proper_value('active?', 'null').should be_nil
      end

      it 'returns the value unchanged' do
        @search.to_proper_value('label', 'Black').should eq('Black')
      end

      it 'should strip any white space' do
        @search.to_proper_value('label', ' Black Label ').should eq('Black Label')
      end
    end

    describe '#text' do
      it 'downcases the text string' do
        Search.new(text: 'McDowall').text.should eq 'mcdowall'
      end

      ['AND', 'OR', 'NOT'].each do |operator|
        it "downcases everything except the #{operator} operators" do
          Search.new(text: "McDowall #{operator} Dogs").text.should eq "mcdowall #{operator} dogs"
        end
      end
    end

    describe '#solr_search_object' do
      it 'memoizes the solr search object' do
        sunspot_mock = double(:solr).as_null_object
        @search.should_receive(:execute_solr_search).once.and_return(sunspot_mock)
        @search.solr_search_object
        @search.solr_search_object.should eq(sunspot_mock)
      end

      it 'sets the solr request parameters when debug=true' do
        @search.options[:debug] = 'true'
        @search.stub(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        @search.solr_request_params.should eq({:param1 => 1})
      end

      it "doesn't set the solr request parameters" do
        @search.stub(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        @search.solr_request_params.should be_nil
      end

      it 'returns a empty hash when solr request fails' do
        @search.options[:debug] = 'true'
        @search.stub(:execute_solr_search) { {} }
        @search.solr_search_object.should eq({})
      end
    end

    describe '#solr_error_message' do
      before {
        @error = double(:error, response: {status: 400, body: 'Solr error'})
        @error.stub(:parse_solr_error_response) { 'Solr error' }
      }

      it 'returns a hash with the solr error title and description' do
        @search.solr_error_message(@error).should eq({title: '400 Bad Request', body: 'Solr error'})
      end
    end

    describe '#method_missing' do
	    it 'delegates any missing method to the solr_search_object' do
	      sso = double(:sso, something_missing: [], hits: [])
	      @search.stub(:solr_search_object).and_return(sso)
	      sso.should_receive(:something_missing)
	      @search.something_missing
	    end

	    it 'returns nil when solr request failed' do
	      @search.stub(:solr_search_object).and_return({})
	      @search.something_missing.should be_nil
	    end
	  end

	  describe '#solr_error_message' do
      before(:each) do
        @error = double(:error, response: {status: 400, body: 'Solr error'})
        @error.stub(:parse_solr_error_response) { 'Solr error' }
      end

      it 'returns a hash with the solr error title and description' do
        @search.solr_error_message(@error).should eq({:title => '400 Bad Request', :body => 'Solr error'})
      end
    end

    describe '#solr_search_object' do
      it 'memoizes the solr search object' do
        sunspot_mock = double(:solr).as_null_object
        @search.should_receive(:execute_solr_search).once.and_return(sunspot_mock)
        @search.solr_search_object
        @search.solr_search_object.should eq(sunspot_mock)
      end

      it 'sets the solr request parameters when debug=true' do
        @search.options[:debug] = 'true'
        @search.stub(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        @search.solr_request_params.should eq({:param1 => 1})
      end

      it "doesn't set the solr request parameters" do
        @search.stub(:execute_solr_search) { double(:solr_request, query: double(:query, to_params: {param1: 1})) }
        @search.solr_search_object
        @search.solr_request_params.should be_nil
      end

      it 'returns a empty hash when solr request fails' do
        @search.options[:debug] = 'true'
        @search.stub(:execute_solr_search) { {} }
        @search.solr_search_object.should eq({})
      end
    end

  end
end
