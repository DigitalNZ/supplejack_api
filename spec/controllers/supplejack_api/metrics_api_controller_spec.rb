require 'spec_helper'
require 'faker'

module SupplejackApi
  describe MetricsApiController, type: :controller, focus: true do
    routes { SupplejackApi::Engine.routes }

    describe 'GET endpoint' do
      let(:api_key) {'apikey'}
      let!(:user) {FactoryGirl.create(:user, authentication_token: api_key, role: 'developer')}

      before do
        5.times do |n|
          create(:daily_item_metric, day: (Date.current + 1.days) - n.days)
          create(:usage_metrics, created_at: (Date.current + 1.days) - n.days)
        end
      end

      it 'responds using the default parameters if none are supplied' do
        get :endpoint, api_key: api_key, version: 'v1'

        expect(response.body).to match_response_schema('metrics/response')
      end
    end
  end
end
