require 'spec_helper'

module SupplejackApi
  describe MetricsApiController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    def build_models
      5.times do |n|
        create(:daily_item_metric, day: Date.current - n.days)
        create(:faceted_metrics, day: Date.current - n.days)
        create(:usage_metrics, created_at: Date.current - n.days)
      end
    end

    describe 'GET root' do
      context "sucessful requests" do
        after do
          expect(response.body).to match_response_schema('metrics/top_level_response')
        end

        it 'responds using the default parameters if none are supplied' do
          build_models

          get :root, version: 'v3'
        end

        it 'retrieves metrics for a range of dates' do
          build_models

          get :root, version: 'v3', start_date: Date.current - 5.days, end_date: Date.current

          json = JSON.parse(response.body)

          expect(json.length).to eq(5)
        end

        it 'correctly retrieves metrics models that were created yesterday with default parameters' do
          create(:daily_item_metric, day: Date.current - 1.day)
          get :root, version: 'v3'

          json = JSON.parse(response.body)

          expect(json.first['total_active_records']).to be_present
        end
      end

      context "failure requests" do
        it 'responds with 404 when requesting metrics for a non-existent date' do
          get :root, version: 'v3', start_date: Date.current - 100.days

          expect(response.status).to eq(404)
        end
      end
    end

    describe 'GET extended' do
      context "succesful requests" do
        after do
          expect(response.body).to match_response_schema('metrics/extended_response')
        end

        it 'retrieves a range of extended metrics, filtered against the facet parameter' do
          create(:faceted_metrics, name: 'dc1', day: Date.yesterday)
          create(:faceted_metrics, name: 'dc2', day: Date.yesterday)
          create(:usage_metrics, record_field_value: 'dc1', day: Date.yesterday)
          create(:usage_metrics, day: Date.yesterday)

          get :extended, version: 'v3', facets: 'dc1', start_date: Date.yesterday, end_date: Date.yesterday
          json = JSON.parse(response.body)

          expect(json.first['record'].count).to eq(1)
          expect(json.first['view'].count).to eq(1)
        end
      end

      context "failure requests" do
        it 'responds with a 400 status if the facets parameter is missing' do
          get :extended, version: 'v3'

          expect(response.status).to eq(400)
        end

        it 'responds with a 400 status if the number of facets requested in greater than 10' do
          get :extended, version: 'v3', facets: '1,2,3,4,5,6,7,8,9,10,11'

          expect(response.status).to eq(400)
        end
      end
    end

    describe 'GET facets' do
      after do
        expect(response.body).to match_response_schema('metrics/facets_response')
      end

      it 'responds with a list of all facets' do
        5.times{create(:faceted_metrics)}

        get :facets, version: 'v3'
        json = JSON.parse(response.body)

        expect(json.length).to eq(5)
      end
    end
  end
end
