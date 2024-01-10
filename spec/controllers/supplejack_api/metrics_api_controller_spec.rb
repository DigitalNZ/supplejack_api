# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe MetricsApiController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    def build_models
      5.times do |n|
        create(:daily_item_metric, date: Time.now.utc.to_date - n.days)
        create(:faceted_metrics, date: Time.now.utc.to_date - n.days)
        create(:collection_metric, created_at: Time.now.utc.to_date - n.days)
      end
    end

    describe 'GET root' do
      context 'succesful requests' do
        after do
          expect(response.body).to match_response_schema('metrics/extended_response')
        end

        it 'retrieves a range of extended metrics, filtered against the facet parameter' do
          create(:faceted_metrics, name: 'dc1', date: Time.now.utc.yesterday.to_date)
          create(:faceted_metrics, name: 'dc2', date: Time.now.utc.yesterday.to_date)
          create(:collection_metric, display_collection: 'dc1', date: Time.now.utc.yesterday.to_date)
          create(:collection_metric, date: Time.now.utc.yesterday.to_date)

          get :root, params: {
            version: 'v3',
            facets: 'dc1',
            start_date: Time.now.utc.yesterday.to_date,
            end_date: Time.now.utc.yesterday.to_date
          }

          json = JSON.parse(response.body)

          expect(json.first['record'].count).to eq(1)
          expect(json.first['view'].count).to eq(1)
        end
      end

      context 'failure requests' do
        it 'responds with a 400 status if the facets parameter is missing' do
          get :root, params: { version: 'v3' }

          expect(response.status).to eq(400)
        end

        it 'responds with a 400 status if the number of facets requested is greater than 10' do
          get :root, params: { version: 'v3', facets: '1,2,3,4,5,6,7,8,9,10,11' }

          expect(response.status).to eq(400)
        end
      end
    end

    describe 'GET facets' do
      before do
        allow(SupplejackApi::FacetsHelper).to receive(:get_list_of_facet_values).with(any_args)
                                                                                .and_return(%w[1 2 3 4 5])
      end

      after do
        expect(response.body).to match_response_schema('metrics/facets_response')
      end

      it 'responds with a list of all facets' do
        5.times { create(:faceted_metrics) }

        get :facets, params: { version: 'v3' }
        json = JSON.parse(response.body)

        expect(json.length).to eq(5)
      end
    end

    describe 'GET top' do
      context 'when requesting record metrics' do
        before do
          5.times do |n|
            create(
              :top_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '111145' => 39, '111148' => 17, '111208' => 16, '111010' => 12, '110800' => 8, '111205' => 1 }
            )
          end

          create(
            :top_metric,
            date: Time.now.utc.to_date - 6.days,
            metric: 'page_views',
            results: { '22231' => 39, '44111' => 17, '12311' => 16, '67612' => 12, '45213' => 8, '76512' => 1 }
          )
        end

        it 'returns the top 10 records for a given metric' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 8.days.ago }

          data = JSON.parse(response.body)['results']

          expect(data.count).to eq 10
        end

        it 'aggregates records with the same record IDs together across multiple days' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 8.days.ago }

          data = JSON.parse(response.body)['results']

          expect(data.first['count']).to eq 195
        end

        it 'appends unique record_ids into the top metric' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 8.days.ago }

          data = JSON.parse(response.body)['results']

          data.map! { |record| record['record_id'] }

          expect(data).to include(22_231)
        end

        it 'defaults unrecognized metric parameter to page_views' do
          get :top, params: { version: 'v3', metric: 'test', start_date: 8.days.ago }

          data = JSON.parse(response.body)

          expect(data['metric']).to eq 'page_views'
        end
      end

      context 'when requesting collection metrics' do
        before do
          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '9001' => 102, '9002' => 50, '9003' => 40, '9004' => 37, '9005' => 30, '9006' => 15 },
              display_collection: '95bfm'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '8002' => 1000, '8003' => 987, '8004' => 800, '8005' => 700, '8006' => 600, '8007' => 52 },
              display_collection: 'Figshare'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '111145' => 390, '111148' => 170, '111208' => 160, '111010' => 120, '110800' => 80,
                         '111205' => 10 },
              display_collection: 'Air Force Museum of New Zealand'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '211145' => 395, '211148' => 178, '211208' => 164, '211010' => 123, '210800' => 81,
                         '211205' => 19 },
              display_collection: 'Archives Central'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '311145' => 391, '311148' => 173, '311208' => 166, '311010' => 123, '310800' => 84,
                         '311205' => 12 },
              display_collection: 'Audio Foundation'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '411145' => 395, '411148' => 175, '411208' => 163, '411010' => 124, '410800' => 82,
                         '411205' => 11 },
              display_collection: 'Charlotte Museum'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '511145' => 392, '511148' => 172, '511208' => 163, '511010' => 126, '510800' => 84,
                         '511205' => 12 },
              display_collection: 'CORE Education'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '611145' => 450, '611148' => 173, '611208' => 163, '611010' => 143, '610800' => 82,
                         '611205' => 15 },
              display_collection: 'DigitalNZ'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '711145' => 393, '711148' => 174, '711208' => 162, '711010' => 126, '710800' => 82,
                         '711205' => 11 },
              display_collection: 'Dunedin City Council Archives'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '811145' => 39, '811148' => 17, '811208' => 16, '811010' => 12, '810800' => 8, '811205' => 1 },
              display_collection: 'Europeana'
            )
          end

          10.times do |n|
            create(
              :top_collection_metric,
              date: Time.now.utc.to_date - n.days,
              metric: 'page_views',
              results: { '911145' => 39, '911148' => 17, '911208' => 16, '911010' => 12, '910800' => 8 },
              display_collection: 'Howick Historical Village'
            )
          end
        end

        it 'returns the top 10 collections for a given metric' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 10.days.ago, type: 'collection' }

          data = JSON.parse(response.body)['results']

          expect(data.count).to eq 10
        end

        it 'aggregates metrics with the same display collections together across multiple days' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 10.days.ago, type: 'collection' }

          data = JSON.parse(response.body)['results']

          expect(data.first['count']).to eq 41_390
        end

        it 'returns the top ten records for each collection' do
          get :top, params: { version: 'v3', metric: 'page_views', start_date: 10.days.ago, type: 'collection' }

          data = JSON.parse(response.body)['results']

          expect(data.first['top_ten_records'].count).to eq(6)
          expect(data.first['top_ten_records'].first['record_id']).to eq(8002)
        end
      end
    end
  end
end
