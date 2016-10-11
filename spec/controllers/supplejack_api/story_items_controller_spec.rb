# frozen_string_literal: true
module SupplejackApi
  RSpec.describe StoryItemsController do
    routes { SupplejackApi::Engine.routes }

    let(:story) { create(:story) }
    let(:user) { story.user }
    let(:api_key) { user.api_key }

    describe 'GET index' do
      context 'successfull request' do
        let(:response_body) { JSON.parse(response.body).map(&:deep_symbolize_keys) }

        before do
          get :index, story_id: story.id.to_s, api_key: api_key, user: api_key
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'should return an Array of Story Items' do
          result = response_body.all? do |item|
            ::StoriesApi::V3::Schemas::StoryItem::BlockValidator.new.call(item).success?
          end

          expect(result).to eq(true)
        end
      end

      context 'unsuccessful requests' do
        it 'returns a 404 if story dosent exist' do
          get :index, story_id: 'madeupkey', api_key: api_key, user: api_key
          expect(response.status).to eq(404)
          expect(JSON.parse(response.body)['errors']).to eq("Story with provided Id madeupkey not found")
        end

        it 'returns a 404 if user dosent exist' do
          get :index, story_id: story.id.to_s, api_key: api_key, user: 'madeupkey'
          expect(response.status).to eq(404)
          expect(JSON.parse(response.body)['errors']).to eq("User with provided Api Key madeupkey not found")
        end
      end
    end

    describe 'GET show' do
      context 'successfull requests' do
        before do
          get :show, story_id: story.id.to_s, id: story.set_items.first.id.to_s, api_key: api_key, user: api_key
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'should return an Array of Story Items' do
          response_item = JSON.parse(response.body).deep_symbolize_keys
          first_item = ::StoriesApi::V3::Presenters::StoryItem.new.call(story.set_items.first)

          expect(response_item).to eq(first_item)
        end
      end

      context 'unsuccessfull requests' do
        it 'should return 404 if Story Item dosent exist' do
          get :show, story_id: story.id.to_s, id: 'storyitemid', api_key: api_key, user: api_key
          expect(response.status).to eq(404)
          expect(JSON.parse(response.body)['errors']).to eq("StoryItem with provided Id storyitemid not found for Story with provided Story Id #{story.id}")
        end
      end
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
