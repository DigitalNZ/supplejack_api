# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe RecordSearch do
    before(:each) do
      @search = RecordSearch.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session
    end

    describe '.role_collection_restrictions' do
      let(:developer)             { double(:scope, role: 'developer') }
      let(:admin)                 { double(:scope, role: 'admin') }
      let(:developer_restriction) do
        double(:developer_restriction, record_exclusions: { is_restricted: true })
      end
      let(:no_restriction)        { double(:no_restriction, record_exclusions: nil) }

      before(:each) do
        allow(RecordSchema).to receive(:roles) { { admin: no_restriction, developer: developer_restriction } }
      end

      it 'should handle nil scope' do
        expect(RecordSearch.role_collection_restrictions(nil, :record_exclusions)).to eq []
      end

      it 'should return nil when no role restrictions are defined in the Schema' do
        expect(RecordSearch.role_collection_restrictions(admin, :record_exclusions)).to eq nil
      end

      it 'should return records when role restrictions are defined in the Schema' do
        expect(RecordSearch.role_collection_restrictions(developer, :record_exclusions)).to eq({ is_restricted: true })
      end
    end

    def query_fields_for_search
      @session.searches.last.last.instance_variable_get(:@query).to_params[:qf]
    end

    def search_fq
      @session.searches.last.last.instance_variable_get(:@query).to_params[:fq]
    end

    describe '#execute_solr_search' do
      let(:names)     { %w[John James] }
      let(:addresses) { ['Te Aro', 'Brooklyn'] }

      before do
        allow(RecordSearch).to receive(:role_collection_restrictions) { [] }
      end

      context 'solr errors' do
        before do
          @sunspot_builder = double(:sunspot_builder).as_null_object
          allow(@search).to receive(:search_builder) { @sunspot_builder }
        end

        it 'rescues from a bad request error' do
          expect(@sunspot_builder).to receive(:execute).and_raise(RSolr::Error::Http.new({}, nil))
          @search.execute_solr_search
        end

        it 'adds a error message for a Solr request error' do
          allow(@sunspot_builder).to receive(:execute).and_raise(RSolr::Error::Http.new({}, nil))
          allow(@search).to receive(:solr_error_message) { 'Problem!' }
          @search.execute_solr_search

          expect(@search.errors.first).to be_a RSolr::Error::Http
        end
      end

      it 'should call keywords method with user input' do
        RecordSearch.new(text: 'dog').execute_solr_search
        expect(@session).to have_search_params(:keywords, 'dog')
      end

      it 'downcases the user entered text' do
        RecordSearch.new(text: 'Dog').execute_solr_search
        expect(@session).to have_search_params(:keywords, 'dog')
      end

      it "doesn't downcase SOLR operators" do
        RecordSearch.new(text: 'dog NOT beach').execute_solr_search
        expect(@session).to have_search_params(:keywords, 'dog NOT beach')
      end

      it "doesn't upcase words containing solr operators" do
        RecordSearch.new(text: 'New Zealand').execute_solr_search
        expect(@session).to have_search_params(:keywords, 'new zealand')
      end

      it "doesn't downcase when targeting a specific field" do
        RecordSearch.new(text: 'name_sm:"John Doe"').execute_solr_search

        expect(@session).to have_search_params(:keywords, 'name_sm:"John Doe"')
      end

      it 'should call WithBoudingBox' do
        RecordSearch.new(geo_bbox: '1,2,3,4').execute_solr_search
        expect(search_fq).to include('lat_lng_llm:[3.0,2.0 TO 1.0,4.0]')
      end

      it 'sets the record_type' do
        RecordSearch.new(text: 'Dog', record_type: 1).execute_solr_search
        expect(search_fq).to include('record_type_i:1')
      end

      it 'does not set record_type if set to all' do
        RecordSearch.new(record_type: 'all').execute_solr_search
        expect(search_fq).to_not include('record_type_i:1')
      end

      it 'restricts the query fields to name' do
        RecordSearch.new(text: 'dog', query_fields: [:name]).execute_solr_search
        expect(query_fields_for_search.split(' ').sort).to eq ['name_text']
      end

      it 'restricts to multiple query fields' do
        RecordSearch.new(text: 'dog', query_fields: %i[name address]).execute_solr_search
        expect(query_fields_for_search.split(' ').sort).to eq %w[address_text name_text]
      end

      it 'should search for all text fields' do
        RecordSearch.new(text: 'dog').execute_solr_search
        expect(query_fields_for_search.split(' ').sort).to include('address_text', 'name_text')
      end

      it "should not use the query fields if text isn't present" do
        RecordSearch.new(query_fields: %i[name address]).execute_solr_search
        expect(query_fields_for_search).to be_nil
      end

      it 'should add any facets in the :facets parameter' do
        RecordSearch.new(facets: 'name, address').execute_solr_search
        expect(@session).to have_search_params(:facet, :name)
        expect(@session).to have_search_params(:facet, :address)
      end

      it 'should limit the amount of facet values' do
        RecordSearch.new(facets: 'name', facets_per_page: 10).execute_solr_search
        expect(@session).to have_search_params(:facet, proc { facet(:name, limit: 10) })
      end

      it 'should offset the facets returned' do
        RecordSearch.new(facets: 'name', facets_per_page: 10, facets_page: 2).execute_solr_search
        expect(@session).to have_search_params(:facet, proc { facet(:name, offset: 10) })
      end

      it 'should restrict results by facet values' do
        RecordSearch.new(and: { address: 'Wellington' }).execute_solr_search
        expect(@session).to have_search_params(:with, :address, 'Wellington')
      end

      it 'should restrict results by multiple facet values' do
        RecordSearch.new(and: { name: 'John Doe', address: 'Wellington' }).execute_solr_search
        expect(@session).to have_search_params(:with, proc do
          all_of do
            with(:name, 'John Doe')
            with(:address, 'Wellington')
          end
        end)
      end

      it 'should preserve commas in facet values' do
        RecordSearch.new(and: { address: '12 Smith St, Te Aro, Wellington' }).execute_solr_search
        expect(@session).to have_search_params(:with, proc do
          all_of do
            with(:address, '12 Smith St, Te Aro, Wellington')
          end
        end)
      end

      it 'should restrict result by multiple facet values if an array is passed' do
        RecordSearch.new(and: { email: ['jd@example.com', 'johnd@test.com'] }).execute_solr_search

        expect(@session)
          .to have_search_params(:with, proc { with(:email).all_of(['jd@example.com', 'johnd@test.com']) })
      end

      it 'converts the string true to a real true' do
        RecordSearch.new(and: { nz_citizen: 'true' }).execute_solr_search
        expect(@session).to have_search_params(:with, :nz_citizen, true)
      end

      it 'converts the string false to a real false' do
        RecordSearch.new(and: { nz_citizen: 'false' }).execute_solr_search
        expect(@session).to have_search_params(:with, :nz_citizen, false)
      end

      it 'executes a prefix query when a star(*) is at the end of the value' do
        RecordSearch.new(and: { name: 'John*' }).execute_solr_search
        expect(@session).to have_search_params(:with, proc { with(:name).starting_with('John') })
      end

      it 'ignores a prefix query if the star(*) is not at the end' do
        RecordSearch.new(and: { name: '*John' }).execute_solr_search
        expect(@session).to have_search_params(:with, :name, '*John')
      end

      it 'should return results matching any of the facet values' do
        RecordSearch.new(or: { email: ['jd@example.com', 'johnd@test.com'], name: 'James Cook' }).execute_solr_search
        expect(@session).to have_search_params(:with, proc do
          any do
            with(:email).any_of(['jd@example.com', 'johnd@test.com'])
            with(:name, 'James Cook')
          end
        end)
      end

      it 'should not return results matching the facet values with comma separated fields' do
        RecordSearch.new(without: { email: 'jd@example.com, johnd@test.com', name: 'James Cook' }).execute_solr_search
        expect(@session).to have_search_params(:without, proc do
          without(:email, ['jd@example.com', 'johnd@test.com'])
          without(:name, ['James Cook'])
        end)
      end

      it 'should not return results matching the facet values with fields given in array' do
        RecordSearch.new(
          without: { email: ['jd@example.com', 'johnd@test.com'], name: 'James Cook' }
        ).execute_solr_search
        expect(@session).to have_search_params(:without, proc do
          without(:email, ['jd@example.com', 'johnd@test.com'])
          without(:name, ['James Cook'])
        end)
      end

      it 'should return results with any value' do
        RecordSearch.new(without: { address: 'nil' }).execute_solr_search
        expect(@session).to have_search_params(:without, :address, nil)
      end

      it 'should sort by the specified field' do
        RecordSearch.new(sort: 'name').execute_solr_search
        expect(@session).to have_search_params(:order_by, :name, :desc)
      end

      it 'should not sort when not specified' do
        RecordSearch.new(sort: '').execute_solr_search
        expect(@session).to_not have_search_params(:order_by, any_param)
      end

      it 'should default to page 1 and 20 per page' do
        RecordSearch.new.execute_solr_search
        expect(@session).to have_search_params(:paginate, page: 1, per_page: 20)
      end

      it 'should change the page and per_page defaults' do
        RecordSearch.new(page: 3, per_page: 40).execute_solr_search
        expect(@session).to have_search_params(:paginate, page: 3, per_page: 40)
      end

      it 'removes records from the search based on role restrictions' do
        allow(RecordSearch).to receive(:role_collection_restrictions) { { nz_citizen: true } }

        @search.execute_solr_search
        expect(@session).to have_search_params(:without, :nz_citizen, true)
      end

      it 'removes records from the search based on multiple restrictions per role' do
        allow(RecordSearch).to receive(:role_collection_restrictions) {
                                 { email: ['jd@example.com', 'johnd@test.com'] }
                               }

        @search.execute_solr_search

        expect(@session)
          .to have_search_params(:without, :email, ['jd@example.com', 'johnd@test.com'])
      end

      it 'should add the lucene string to the solr :q.alt parameter' do
        RecordSearch.new(solr_query: 'title:dogs').execute_solr_search

        alt = @session.searches.last.last.instance_variable_get(:@query).to_params['q.alt']
        expect(alt).to eq('title:dogs')
      end

      context 'nested queries' do
        it 'joins name values with a OR query' do
          RecordSearch.new(and: { name: { or: names } }).execute_solr_search
          expect(@session).to have_search_params(:with, proc { with(:name).any_of(names) })
        end

        it 'joins two facets with OR but values within each filter with AND' do
          RecordSearch.new(or: { name: { and: names }, address: { and: addresses } }).execute_solr_search
          expect(@session).to have_search_params(:with, proc do
            any do
              with(:name).all_of(names)
              with(:address).all_of(addresses)
            end
          end)
        end

        it 'joins two AND conditions with OR, one AND condition contains multiple fields' do
          RecordSearch.new(
            or: {
              name: { and: names },
              and: { address: 'Wellington', nz_citizen: 'true' }
            }
          ).execute_solr_search
          expect(@session).to have_search_params(:with, proc do
            any do
              with(:name).all_of(names)
              all do
                with(:address, 'Wellington')
                with(:nz_citizen, 'true')
              end
            end
          end)
        end

        it 'nesting OR and AND conditions 3 levels deep' do
          RecordSearch.new(
            and: {
              name: 'John',
              or: { address: 'Wellington', and: { nz_citizen: 'true', email: 'john@test.com' } }
            }
          ).execute_solr_search

          expect(@session).to have_search_params(:with, proc do
            all do
              with(:name, 'John')
              any do
                with(:address, 'Wellington')
                all do
                  with(:nz_citizen, 'true')
                  with(:email, 'john@test.com')
                end
              end
            end
          end)
        end

        it 'joins options[:and] and options[:or] conditions with AND' do
          RecordSearch.new(
            and: { name: { or: names }, nz_citizen: 'true' },
            or: { address: addresses }
          ).execute_solr_search
          expect(@session).to have_search_params(:with, proc do
            all do
              all do
                with(:name).any_of(names)
                with(:nz_citizen, 'true')
              end
              with(:address).any_of(addresses)
            end
          end)
        end

        it 'nests multiple filters with :or queries in their values' do
          RecordSearch.new(
            and: {
              name: { or: names },
              nz_citizen: 'true',
              address: { or: addresses }
            }
          ).execute_solr_search
          expect(@session).to have_search_params(:with, proc do
            all do
              with(:name).any_of(names)
              with(:nz_citizen, 'true')
              with(:address).any_of(addresses)
            end
          end)
        end
      end

      context 'facet queries' do
        def facet_query_params
          @session.searches.last.last.instance_variable_get(:@query).to_params[:'facet.query']
        end

        it 'queries for all of given facet' do
          RecordSearch.new({ facet_query: { email: { email: 'all' } } }).execute_solr_search
          expect(facet_query_params).to eq('email_sm:[* TO *]')
        end

        it 'queries for records with name "John"' do
          RecordSearch.new({ facet_query: { people: { name: 'John' } } }).execute_solr_search
          expect(facet_query_params).to eq('name_s:John')
        end

        it 'queries for records without name "James"' do
          RecordSearch.new({ facet_query: { people: { '-name' => 'James' } } }).execute_solr_search
          expect(facet_query_params).to eq('-name_s:James')
        end

        it 'correctly reads a "false" value' do
          RecordSearch.new({ facet_query: { citizens: { nz_citizen: 'false' } } }).execute_solr_search
          expect(facet_query_params).to eq('nz_citizen_b:false')
        end

        it 'queries for records with category Images and Videos' do
          RecordSearch.new({ facet_query: { people: { name: names  } } }).execute_solr_search
          expect(facet_query_params).to eq('name_s:(John AND James)')
        end
      end

      it 'removes blacklisted collections from results' do
        create(:source, source_id: 'DNZ', status: 'suppressed')
        @search.execute_solr_search
        expect(@session).to have_search_params(:without, :source_id, ['DNZ'])
      end

      it 'defaults to exclude_filters_from_facets == false' do
        @search.execute_solr_search
        expect(@search.options.exclude_filters_from_facets).to eq false
      end

      context 'exclude_filters_from_facets == true' do
        it 'exclude filters from ORed facets' do
          RecordSearch.new(
            or: { name: names, address: addresses },
            facets: 'name, address',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:facet) {
            name_filter = with(:name, names)
            facet(:name, exclude: name_filter)

            address_filter = with(:address, addresses)
            facet(:address, exclude: address_filter)
          }
        end

        it 'exclude filters from ANDed facets' do
          RecordSearch.new(
            and: { name: names, address: addresses },
            facets: 'name, address',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search
          expect(@session).to have_search_params(:facet) {
            name_filter = with(:name, names)
            facet(:name, exclude: name_filter)

            address_filter = with(:address, addresses)
            facet(:address, exclude: address_filter)
          }
        end

        it 'excludes filters from AND filters if there are OR filters nested inside' do
          RecordSearch.new(
            and: {
              subject: { or: %w[Birds Plants] },
              category: { or: %w[Image Video] }
            },
            facets: 'subject,category',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:facet) {
            subject_filter = with(:subject, %w[Birds Plants])
            facet(:subject, exclude: subject_filter)

            category_filter = with(:category, %w[Image Video])
            facet(:category, exclude: category_filter)
          }
        end

        it 'does not add additional facets into the search' do
          RecordSearch.new(
            and: { category: ['Audio'], subject: ['forest'] },
            facets: 'category',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:facet) {
            category_filter = with(:category, ['Audio'])
            facet(:category, exclude: category_filter)
          }

          expect(@session).not_to have_search_params(:facet) {
            subject_filter = with(:subject, ['forest'])
            facet(:subject, exclude: subject_filter)
          }
        end

        it 'does not add facets into the search when you aren\'t asking for any' do
          RecordSearch.new(
            and: { category: ['Audio'], subject: ['forest'] },
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).not_to have_search_params(:facet) {
            category_filter = with(:category, ['Audio'])
            facet(:category, exclude: category_filter)
          }

          expect(@session).not_to have_search_params(:facet) {
            subject_filter = with(:subject, ['forest'])
            facet(:subject, exclude: subject_filter)
          }
        end

        it 'handles integer facets correctly' do
          RecordSearch.new(
            and: { age: ['10'], subject: ['forest'] },
            facets: 'age',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:facet) {
            age_filter = with(:age_str, ['10'])
            facet(:age_str, exclude: age_filter)
          }
        end

        it 'handles Boolean facets correctly' do
          RecordSearch.new(
            and: { nz_citizen: 'false' },
            facets: 'nz_citizen',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:with, proc do
            all_of do
              with(:nz_citizen, false)
            end
          end)
        end

        it 'handles nil facets correctly' do
          RecordSearch.new(
            and: { email: 'nil' },
            facets: 'email',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:with, proc do
            all_of do
              with(:email, nil)
            end
          end)
        end

        it 'handles nul facets correctly' do
          RecordSearch.new(
            and: { email: 'null' },
            facets: 'email',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:with, proc do
            all_of do
              with(:email, nil)
            end
          end)
        end

        it 'applies filters that are given as strings via the URL correctly' do
          RecordSearch.new(
            and: { category: %w[Images] },
            facets: 'subject, category',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:facet) {
            category_filter = with(:category, %w[Images])
            facet(:category, exclude: category_filter)
          }
        end

        it 'applies filters that are given which are not facets' do
          RecordSearch.new(
            and: { category: %w[Images] },
            facets: 'subject',
            exclude_filters_from_facets: 'true'
          ).execute_solr_search

          expect(@session).to have_search_params(:with, :category, %w[Images])
          expect(@session).to have_search_params(:facet, :subject)
          expect(@session).not_to have_search_params(:facet, :category)
        end
      end
    end
  end
end
