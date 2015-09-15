require 'spec_helper'
require 'faker'

module SupplejackApi
  describe MetricsApiController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    describe 'GET endpoint' do
      let(:api_key) {'apikey'}
      let!(:user) {FactoryGirl.create(:user, authentication_token: api_key, role: 'developer')}

      context "sucessful requests" do
        def build_models
          5.times do |n|
            create(:daily_item_metric, day: Date.current - n.days)
            create(:usage_metrics, created_at: Date.current - n.days)
          end
        end

        after do
          expect(response.body).to match_response_schema('metrics/response')
        end

        it 'responds using the default parameters if none are supplied' do
          build_models

          get :endpoint, api_key: api_key, version: 'v1'
        end

        it 'retrieves metrics for a range of dates' do
          build_models

          get :endpoint, api_key: api_key, version: 'v1', start_date: Date.current - 5.days, end_date: Date.current

          json = JSON.parse(response.body)

          expect(json.length).to eq(5)
        end

        it 'correctly retrieves metrics models that were created yesterday with default parameters' do
          create(:daily_item_metric, day: Date.current - 1.day)
          get :endpoint, api_key: api_key, version: 'v1'

          json = JSON.parse(response.body)

          expect(json.first['display_collection']).to be_present
        end
      end

      context "failure requests" do
        it 'responds with 404 when requesting metrics for a non-existent date' do
          get :endpoint, api_key: api_key, version: 'v1', start_date: Date.current - 100.days

          expect(response.status).to eq(404)
        end

        it 'responds with 403 if api_key is invalid' do
          get :endpoint, api_key: 'junk', version: 'v1'

          expect(response.status).to eq(403)
        end
      end
    end
  end
end
