# frozen_string_literal: true
module SupplejackApi
  RSpec.describe StoryItemsController do
    routes { SupplejackApi::Engine.routes }

    let(:story) { create(:story) }
    let(:user) { story.user }
    let(:api_key) { user.api_key }

    describe 'GET index' do
      context 'successfull request' do
        it 'returns a 200 http code' do
          get :index, story_id: story.id.to_s, api_key: api_key, user: api_key
          # binding.pry
          expect(response.status).to eq(200)
        end
      end
    end

    describe 'GET show' do
    end

    describe 'POST create' do
    end

    describe 'DELETE create' do
    end

    describe 'PATCH update' do
    end

    describe 'PUT update' do
    end    
  end
end
