# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe IndexInvalidationsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:user) { create(:user) }

    before do
      allow(controller).to receive(:current_user) { user }
      allow(controller).to receive(:authenticate_user!) { true }
    end

    describe 'GET token' do
      it 'returns the current token' do
        invalidation = IndexInvalidation.create

        get :token, format: :json

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['token']).to eq(invalidation.token)
      end
    end
  end
end
