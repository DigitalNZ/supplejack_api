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
      before do
        5.times do |n|
          create(
            :top_metric,
            date: Time.now.utc.to_date - n.days,
            metric: 'page_views',
            results: { "111145"=>39, "111148"=>17, "111208"=>16, "111010"=>12, "110800"=>8, "111205"=>1 }
          )
        end

        create(
          :top_metric,
          date: Time.now.utc.to_date - 6.days,
          metric: 'page_views',
          results: { "22231"=>39, "44111"=>17, "12311"=>16, "67612"=>12, "45213"=>8, "76512"=>1 }
        )
      end

      it 'returns the top 10 records for a given metric' do
        get :top, params: { version: 'v3', metric: 'page_views', start_date: 6.days.ago }

        data = JSON.parse(response.body)

        expect(data.count).to eq 10
      end

      it 'aggregates records with the same record IDs together across multiple days' do
        get :top, params: { version: 'v3', metric: 'page_views', start_date: 6.days.ago }

        data = JSON.parse(response.body)

        expect(data.first['count']).to eq 195
      end

      it 'appends unique record_ids into the top metric' do
        get :top, params: { version: 'v3', metric: 'page_views', start_date: 6.days.ago }

        data = JSON.parse(response.body)

        data.map! { |record| record['record_id'] }

        expect(data).to include(22_231)
      end

      it 'defaults unrecognized metrics to page_views' do
        get :top, params: { version: 'v3', metric: 'test', start_date: 6.days.ago }

        data = JSON.parse(response.body)

        expect(data.count).to eq 10
      end
    end
  end
end
