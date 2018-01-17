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
      u = SupplejackApi::User.sortable(order: :daily_requests_desc)
      expect(JSON.parse(response.body)['users']).to eq u.map { |x| SupplejackApi::Harvester::UserSerializer.new(x).as_json.as_json }
    end

    it 'requires an API key' do
      get :index, format: :json
      expect(response.status).to eq 403
    end

    it 'requires an API key with harvester privilages' do
      get :index, format: :json, params: { api_key: developer_api_key }
      expect(response.status).to eq 403
    end

    context 'attributes' do
      before do
        get :index, params: { api_key: harvester_api_key }, format: :json
        @user = JSON.parse(response.body)['users'].first
      end

      it 'renders the :id' do
        expect(@user).to have_key 'id'
      end

      it 'renders the :username' do
        expect(@user).to have_key 'username'
      end

      it 'renders the :name' do
        expect(@user).to have_key 'name'
      end

      it 'renders the :authentication_token' do
        expect(@user).to have_key 'authentication_token'
      end

      it 'renders the :email' do
        expect(@user).to have_key 'email'
      end

      it 'renders the :role' do
        expect(@user).to have_key 'role'
      end

      it 'renders the :daily_requests' do
        expect(@user).to have_key 'daily_requests'
      end

      it 'renders the :monthly_requests' do
        expect(@user).to have_key 'monthly_requests'
      end

      it 'renders the :max_requests' do
        expect(@user).to have_key 'max_requests'
      end
    end
  end
end
