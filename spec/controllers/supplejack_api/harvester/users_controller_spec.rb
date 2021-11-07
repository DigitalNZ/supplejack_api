# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::UsersController do
  routes { SupplejackApi::Engine.routes }

  let(:harvester_api_key) { create(:user, role: 'harvester').api_key }
  let(:developer_api_key) { create(:user, role: 'developer').api_key }
  let!(:users)  { create_list(:user, 5) }

  describe '#index' do
    it 'renders a succesful status code' do
      get :index, params: { api_key: harvester_api_key }, format: :json
      expect(response.status).to eq 200
    end

    it 'renders the @users as JSON' do
      get :index, params: { api_key: harvester_api_key }, format: :json
      userss = SupplejackApi::User.all.map { |x| SupplejackApi::Harvester::UserSerializer.new(x).as_json.as_json }

      expect(JSON.parse(response.body)['users']).to eq userss
    end

    it 'requires an API key' do
      get :index, format: :json
      expect(response.status).to eq 401
    end

    it 'requires an API key with harvester privilages' do
      get :index, format: :json, params: { api_key: developer_api_key }
      expect(response.status).to eq 401
    end
  end

  describe '#update' do
    let(:user) { users.first }

    it 'can update the max request limit' do
      patch :update, params: { id: user, api_key: harvester_api_key, user: { max_requests: 10 } }
      user.reload
      expect(user.max_requests).to eq 10
    end

    it 'requires an API key' do
      patch :update, params: { id: user, api_key: developer_api_key, user: { max_requests: 10 } }
      expect(response.status).to eq 401
    end
  end

  describe '#show' do
    let(:user) { users.first }

    before do
      get :show, params: { id: user.id, api_key: harvester_api_key }
    end

    it 'renders the user as JSON' do
      expect(JSON.parse(response.body)).to eq SupplejackApi::Harvester::UserSerializer.new(user).as_json.as_json
    end

    it 'responds with a successful status code' do
      expect(response.status).to eq 200
    end
  end
end
