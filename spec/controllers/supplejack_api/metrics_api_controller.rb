require 'spec_helper'
require 'faker'

module SupplejackApi
  describe MetricsApiController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    def create_daily_item_metric(day = Date.current, number_of_display_collections = 2)
      display_collection_attributes = number_of_display_collections.times.map do
        {
          name: Faker::Company.name,
          total_active_records: 1,
          total_new_records: 1,
          category_counts: {'stuff' => 1},
          copyright_counts: {'rights' => 1}
        }
      end
      DailyItemMetric.create(
        day: day,
        total_active_records: 30,
        display_collection_metrics_attributes: display_collection_attributes
      )
    end

    describe 'GET endpoint' do
      let(:api_key) {'apikey'}
      let!(:user) {FactoryGirl.create(:user, authentication_token: api_key, role: 'developer')}

      before do
        5.times do |n|
          create_daily_item_metric(Date.current + n.days)
        end
      end

      it 'responds using the default parameters if none are supplied' do
        get :endpoint, api_key: api_key, version: 'v1'

        expect(response.body).to match_response_schema('metrics/response')
      end
    end
  end
end
