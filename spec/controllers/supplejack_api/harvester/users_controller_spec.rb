# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SupplejackApi::Harvester::UsersController do
  routes { SupplejackApi::Engine.routes }

  let(:harvester) { create(:harvest_user) }
  let(:user)      { create(:user) }
  let!(:users)    { create_list(:user, 2) }

  describe '#index' do
    it 'renders a succesful status code' do
      get :index, params: { api_key: harvester.api_key }, format: :json

      expect(response).to be_successful
    end

    it 'renders the @users as JSON' do
      get :index, params: { api_key: harvester.api_key }, format: :json
      userss = SupplejackApi::User.all.map { |x| SupplejackApi::Harvester::UserSerializer.new(x).as_json.as_json }

      expect(JSON.parse(response.body)['users']).to eq userss
    end

    it 'requires an API key' do
      get :index, format: :json

      expect(response).to be_unauthorized
    end

    it 'requires an API key with harvester privilages' do
      get :index, format: :json, params: { api_key: user.api_key }

      expect(response).to be_unauthorized
    end
  end

  describe '#update' do
    let(:user) { users.first }

    it 'can update the max request limit' do
      patch :update, params: { id: user, api_key: harvester.api_key, user: { max_requests: 10 } }
      user.reload

      expect(user.max_requests).to eq 10
    end

    it 'requires an API key' do
      patch :update, params: { id: user, api_key: user.api_key, user: { max_requests: 10 } }

      expect(response).to be_unauthorized
    end
  end

  describe '#show' do
    let(:user) { users.first }

    before do
      get :show, params: { id: user.id, api_key: harvester.api_key }
    end

    it 'renders the user as JSON' do
      expect(JSON.parse(response.body)).to eq SupplejackApi::Harvester::UserSerializer.new(user).as_json.as_json
    end

    it 'responds with a successful status code' do
      expect(response).to be_successful
    end
  end
end
