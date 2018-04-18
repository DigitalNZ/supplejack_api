# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::ActivitiesController do
  routes { SupplejackApi::Engine.routes }

  let(:harvester_api_key) { create(:user, role: 'harvester').api_key }
  let(:developer_api_key) { create(:user, role: 'developer').api_key }

  let!(:activites) { create_list(:activity, 5) }

  describe '#index' do
    context 'with an API key with harvester privelages' do
      it 'renders a successful status code' do
        get :index, params: { api_key: harvester_api_key }, format: :json
        expect(response).to have_http_status(200)
      end

      it 'renders the site activites as an array of JSON' do
        get :index, params: { api_key: harvester_api_key }, format: :json
        expect(JSON.parse(response.body)['site_activities'].count).to eq 5
      end
    end

    context 'without an API key' do
      it 'returns 403 unauthorized' do
        get :index, format: :json
        expect(response).to have_http_status(403)
      end
    end
  end
end
