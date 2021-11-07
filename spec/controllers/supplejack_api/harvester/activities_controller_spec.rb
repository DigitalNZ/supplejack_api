# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::ActivitiesController do
  routes { SupplejackApi::Engine.routes }

  let(:harvester_api_key) { create(:user, role: 'harvester').api_key }
  let(:developer_api_key) { create(:user, role: 'developer').api_key }

  let!(:activites) { create_list(:activity, 5) }

  describe '#index' do
    context 'when requested with harvester API key' do
      it 'renders a successful status code' do
        get :index, params: { api_key: harvester_api_key }, format: :json

        expect(response).to have_http_status(200)
      end

      it 'renders the site activites as an array of JSON' do
        get :index, params: { api_key: harvester_api_key }, format: :json

        expect(JSON.parse(response.body)['site_activities'].count).to eq 5
      end
    end

    context 'when requested with developer API key' do
      it 'returns 401 unauthorized' do
        get :index, params: { api_key: developer_api_key }, format: :json

        expect(response).to have_http_status(401)
      end
    end

    context 'when requested without API key' do
      it 'returns 401 unauthorized' do
        get :index, format: :json

        expect(response).to have_http_status(401)
      end
    end
  end
end
