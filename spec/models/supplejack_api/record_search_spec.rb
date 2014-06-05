# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RecordSearch do
  	before(:each) do
      @search = RecordSearch.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      RecordSearch.stub(:role_collection_restrictions) { [] }
    end

    describe '.role_collection_restrictions' do
      let(:developer) { double(:scope, role: 'developer') }
      let(:admin) { double(:scope, role: 'admin') }
      let(:developer_restriction) { double(:developer_restriction, record_restrictions: {is_restricted: true}) }
      let(:no_restriction) { double(:no_restriction, record_restrictions: nil) }

      before(:each) do
        RecordSearch.unstub(:role_collection_restrictions)
        RecordSchema.stub(:roles) { {admin: no_restriction, developer: developer_restriction} }
      end

      it 'should handle nil scope' do
        RecordSearch.role_collection_restrictions(nil).should eq []
      end

      it 'should return nil when no role restrictions are defined in the Schema' do
        RecordSearch.role_collection_restrictions(admin).should eq []
      end

      it 'should return nil when no role restrictions are defined in the Schema' do
        RecordSearch.role_collection_restrictions(developer).should eq({is_restricted: true})
      end
    end

    def query_fields_for_search
      @session.searches.last.last.instance_variable_get(:@query).to_params[:qf]
    end

    describe '#execute_solr_search' do
      context 'solr errors' do
        before do
          @sunspot_builder = double(:sunspot_builder).as_null_object
          @search.stub(:search_builder) { @sunspot_builder }
        end
  
        it 'rescues from a bad request error' do
          @sunspot_builder.stub(:execute).and_raise(RSolr::Error::Http.new({}, {}))
          @search.execute_solr_search
        end
  
        it 'adds a error message for a Solr request error' do
          @sunspot_builder.stub(:execute).and_raise(RSolr::Error::Http.new({}, {}))
          @search.stub(:solr_error_message) { 'Problem!' }
          @search.execute_solr_search
          @search.errors.first.should eq 'Problem!'
        end
  
        [Timeout::Error, Errno::ECONNREFUSED, Errno::ECONNRESET].each do |error_klass|
          it 'adds a error message for a #{Timeout::Error} error' do
            @sunspot_builder.stub(:execute).and_raise(error_klass)
            @search.execute_solr_search.should eq({})
            @search.errors.first.should eq 'Solr is temporarily unavailable please try again in a few seconds.'
          end
        end
      end
  
      it 'should call keywords method with user input' do
        @search.options[:text] = 'dog'
        @search.execute_solr_search
        @session.should have_search_params(:keywords, 'dog')
      end
  
      it 'downcases the user entered text' do
        @search.options[:text] = 'Dog'
        @search.execute_solr_search
        @session.should have_search_params(:keywords, 'dog')
      end
  
      it "doesn't downcase SOLR operators" do
        @search.options[:text] = 'dog NOT beach'
        @search.execute_solr_search
        @session.should have_search_params(:keywords, 'dog NOT beach')
      end
  
      it "doesn't upcase words containing solr operators" do
        @search.options[:text] = 'New Zealand'
        @search.execute_solr_search
        @session.should have_search_params(:keywords, 'new zealand')
      end
  
      it "doesn't downcase when targeting a specific field" do
        @search.options[:text] = "name_sm:\"John Doe\""
        @search.execute_solr_search
        @session.should have_search_params(:keywords, "name_sm:\"John Doe\"")
      end
  
      it 'restricts the query fields to name' do
        @search.options[:text] = 'dog'
        @search.options[:query_fields] = [:name]
        @search.execute_solr_search
        query_fields_for_search.split(' ').sort.should eq ['name_text']
      end
  
      it 'restricts to multiple query fields' do
        @search.options[:text] = 'dog'
        @search.options[:query_fields] = [:name, :address]
        @search.execute_solr_search
        query_fields_for_search.split(' ').sort.should eq ['address_text', 'name_text']
      end
  
      it 'should search for all text fields' do
        @search.options[:text] = 'dog'
        @search.execute_solr_search
        query_fields_for_search.split(' ').sort.should include('address_text', 'name_text')
      end
  
      it "should not use the query fields if text isn't present" do
        @search.options[:query_fields] = [:name, :address]
        @search.execute_solr_search
        query_fields_for_search.should be_nil
      end

      it 'should add any facets in the :facets parameter' do
        @search.options[:facets] = 'name, address'
        @search.execute_solr_search
        @session.should have_search_params(:facet, :name)
        @session.should have_search_params(:facet, :address)
      end
  
      it 'should limit the amount of facet values' do
        @search.options.merge!(facets: 'name', facets_per_page: 10)
        @search.execute_solr_search
        @session.should have_search_params(:facet, Proc.new {
          facet(:name, :limit => 10)
        })
      end
  
      it 'should offset the facets returned' do
        @search.options.merge!(facets: 'name', facets_per_page: 10, facets_page: 2)
        @search.execute_solr_search
        @session.should have_search_params(:facet, Proc.new {
          facet(:name, :offset => 10)
        })
      end
  
      it 'should restrict results by facet values' do
        @search.options[:and] = {address: 'Wellington'}
        @search.execute_solr_search
        @session.should have_search_params(:with, :address, 'Wellington')
      end
  
      it 'should restrict results by multiple facet values' do
        @search.options[:and] = {name: 'John Doe', address: 'Wellington'}
        @search.execute_solr_search
        @session.should have_search_params(:with, Proc.new {
          all_of do
            with(:name, 'John Doe')
            with(:address, 'Wellington')
          end
        })
      end
  
      it 'should preserve commas in facet values' do
        @search.options[:and] = {address: '12 Smith St, Te Aro, Wellington'}
        @search.execute_solr_search
        @session.should have_search_params(:with, Proc.new {
          all_of do
            with(:address, '12 Smith St, Te Aro, Wellington')
          end
        })
      end
  
      it 'should restrict result by multiple facet values if an array is passed' do
        @search.options[:and] = {email: ['jd@example.com', 'johnd@test.com']}
        @search.execute_solr_search
        @session.should have_search_params(:with, Proc.new {
          with(:email).all_of(['jd@example.com', 'johnd@test.com'])
        })
      end
  
      it 'converts the string true to a real true' do
        @search.options[:and] = {nz_citizen: 'true'}
        @search.execute_solr_search
        @session.should have_search_params(:with, :nz_citizen, true)
      end
  
      it 'converts the string false to a real false' do
        @search.options[:and] = {nz_citizen: 'false'}
        @search.execute_solr_search
        @session.should have_search_params(:with, :nz_citizen, false)
      end
  
      it 'executes a prefix query when a star(*) is at the end of the value' do
        @search.options[:and] = {name: 'John*'}
        @search.execute_solr_search
        @session.should have_search_params(:with, Proc.new {
          with(:name).starting_with('John')
        })
      end
  
      it 'ignores a prefix query if the star(*) is not at the end' do
        @search.options[:and] = {name: '*John'}
        @search.execute_solr_search
        @session.should have_search_params(:with, :name, '*John')
      end
  
      it 'should return results matching any of the facet values' do
        @search.options[:or] = {email: ['jd@example.com', 'johnd@test.com'], name: 'James Cook'}
        @search.execute_solr_search
        @session.should have_search_params(:with, Proc.new {
          any_of do
            with(:email).any_of(['jd@example.com', 'johnd@test.com'])
            with(:name, 'James Cook')
          end
        })
      end
  
      it 'should not return results matching the facet values' do
        @search.options[:without] = {email: 'jd@example.com, johnd@test.com', name: 'James Cook'}
        @search.execute_solr_search
        @session.should have_search_params(:without, Proc.new {
          without(:email, 'jd@example.com')
          without(:email, 'johnd@test.com')
          without(:name, 'James Cook')
        })
      end
  
      it 'should return results with any value' do
        @search.options[:without] = {address: 'nil'}
        @search.execute_solr_search
        @session.should have_search_params(:without, :address, nil)
      end
  
      it 'should sort by the specified field' do
        @search.options[:sort] = 'name'
        @search.execute_solr_search
        @session.should have_search_params(:order_by, :name, :desc)
      end
  
      it 'should not sort when not specified' do
        @search.options[:sort] = ''
        @search.execute_solr_search
        @session.should_not have_search_params(:order_by, any_param)
      end
  
      it 'should default to page 1 and 20 per page' do
        @search.execute_solr_search
        @session.should have_search_params(:paginate, page: 1, per_page: 20)
      end
  
      it 'should change the page and per_page defaults' do
        @search.options.merge!(page: 3, per_page: 40)
        @search.execute_solr_search
        @session.should have_search_params(:paginate, page: 3, per_page: 40)
      end
  
      it 'removes records from the search based on role restrictions' do
        RecordSearch.stub(:role_collection_restrictions) { {nz_citizen: true} }
  
        @search.execute_solr_search
        @session.should have_search_params(:without, :nz_citizen, true)
      end
  
      it 'removes records from the search based on multiple restrictions per role' do
        RecordSearch.stub(:role_collection_restrictions) { {email: ['jd@example.com', 'johnd@test.com']} }
  
        @search.execute_solr_search
        @session.should have_search_params(:without, :email, ['jd@example.com', 'johnd@test.com'])
      end
  
      it 'should add the lucene string to the solr :q.alt parameter' do
        @search.options.merge!(solr_query: 'title:dogs')
        @search.execute_solr_search
  
        alt = @session.searches.last.last.instance_variable_get(:@query).to_params['q.alt']
        alt.should eq('title:dogs')
      end
  
      it 'should add spellcheck if suggest parameter is true' do
        @search.options.merge!(suggest: true)
        @search.execute_solr_search
        @session.searches.last.last.instance_variable_get(:@query).to_params[:spellcheck].should be_true
        @session.searches.last.last.instance_variable_get(:@query).to_params['spellcheck.collate'].should be_true
        @session.searches.last.last.instance_variable_get(:@query).to_params['spellcheck.onlyMorePopular'].should be_true
      end
  
      context 'nested queries' do
        it 'joins name values with a OR query' do
          @search.options[:and] = {name: {or: ['John', 'James']}}
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            with(:name).any_of(['John', 'James'])
          })
        end
  
        it 'joins two facets with OR but values within each filter with AND' do
          @search.options[:or] = {name: {and: ['John', 'James']}, address: {and: ['Wellington', 'Auckland']} }
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            any_of do
              with(:name).all_of(['John', 'James'])
              with(:address).all_of(['Wellington', 'Auckland'])
            end
          })
        end
  
        it 'joins two AND conditions with OR, one AND condition contains multiple fields' do
          @search.options[:or] = {name: {and: ['John', 'James']}, and: {address: 'Wellington', nz_citizen: 'true'} }
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            any_of do
              with(:name).all_of(['John', 'James'])
              all_of do
                with(:address, 'Wellington')
                with(:nz_citizen, 'true')
              end
            end
          })
        end
  
        it 'nesting OR and AND conditions 3 levels deep' do
          @search.options[:and] = {name: 'John', or: {address: 'Wellington', and: {nz_citizen: 'true', email: 'john@test.com'}}}
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            all_of do
              with(:name, 'John')
              any_of do
                with(:address, 'Wellington')
                all_of do
                  with(:nz_citizen, 'true')
                  with(:email, 'john@test.com')
                end
              end
            end
          })
        end
  
        it 'joins options[:and] and options[:or] conditions with AND' do
          @search.options[:and] = {name: {or: ['John', 'James']}, nz_citizen: 'true'}
          @search.options[:or] = {address: ['Wellington', 'Auckland']}
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            all_of do
              all_of do
                with(:name).any_of(['John', 'James'])
                with(:nz_citizen, 'true')
              end
              with(:address).any_of(['Wellington', 'Auckland'])
            end
          })
        end
  
        it 'nests multiple filters with :or queries in their values' do
          @search.options[:and] = {name: {or: ['John', 'James']}, nz_citizen: 'true', address: {or: ['Wellington', 'Auckland']}}
          @search.execute_solr_search
          @session.should have_search_params(:with, Proc.new {
            all_of do
              with(:name).any_of(['John', 'James'])
              with(:nz_citizen, 'true')
              with(:address).any_of(['Wellington', 'Auckland'])
            end
          })
        end
      end
  
      context 'facet queries' do
        def facet_query_params
          @session.searches.last.last.instance_variable_get(:@query).to_params[:'facet.query']
        end
  
        it 'queries for all of given facet' do
          @search.options.merge!({facet_query: {email: {email: 'all'}}})
          @search.execute_solr_search
          facet_query_params.should eq('email_sm:[* TO *]')
        end
  
        it 'queries for records with name "John"' do
          @search.options.merge!({facet_query: {people: {'name' => 'John'}}})
          @search.execute_solr_search
          facet_query_params.should eq('name_s:John')
        end
  
        it 'queries for records without name "James"' do
          @search.options.merge!({facet_query: {people: {'-name' => 'James'}}})
          @search.execute_solr_search
          facet_query_params.should eq('-name_s:James')
        end
        
        it 'correctly reads a "false" value' do
          @search.options.merge!({facet_query: {citizens: {'nz_citizen' => 'false'}}})
          @search.execute_solr_search
          facet_query_params.should eq('nz_citizen_b:false')
        end
        
        it 'queries for records with category Images and Videos' do
          @search.options.merge!({facet_query: {people: {'name' => ['John', 'James']}}})
          @search.execute_solr_search
          facet_query_params.should eq('name_s:(John AND James)')
        end
      end
  
      it 'removes blacklisted collections from results' do
        FactoryGirl.create(:source, source_id: 'DNZ', status: 'suppressed' )
        @search.execute_solr_search
        @session.should have_search_params(:without, :source_id, 'DNZ')
      end
    end

  end

end
