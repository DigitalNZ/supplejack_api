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

        before { get :index, params: { story_id: story.id.to_s, api_key: api_key, user_key: api_key } }

        it 'returns a 200 http code' do
          expect(response).to be_successful
        end

        it 'should return an Array of Story Items' do
          story.set_items.each do |item|
            expect(response_body).to include(StoryItemSerializer.new(item).as_json)
          end
        end
      end

      context 'unsuccessful requests' do
        it 'returns 400 if user_key not passed' do
          get :index, params: { story_id: 'madeupkey', api_key: api_key }

          expect(response).to be_not_found
        end

        it 'returns a 404 if story dosent exist' do
          get :index, params: { story_id: 'madeupkey', api_key: api_key, user_key: api_key }

          expect(response).to be_not_found
          expect(JSON.parse(response.body)['errors']).to eq('Story with provided Id madeupkey not found')
        end

        it 'returns a 404 if user dosent exist' do
          get :index, params: { story_id: story.id.to_s, api_key: 'madeupkey' }

          expect(response.status).to eq(403)
          expect(JSON.parse(response.body)['errors']).to eq('Invalid API Key')
        end
      end
    end

    describe 'GET show' do
      context 'successfull requests' do
        before do
          get :show,
              params: {
                story_id: story.id.to_s,
                id: story.set_items.first.id.to_s,
                api_key: api_key,
                user_key: api_key
              }
        end

        it 'returns a 200 http code' do
          expect(response).to be_successful
        end

        it 'should return a Story Items' do
          response_item = JSON.parse(response.body).deep_symbolize_keys
          first_item = StoryItemSerializer.new(story.set_items.first).as_json

          response_item.delete(:id)
          first_item.delete(:id)

          expect(response_item).to eq first_item
        end
      end

      context 'unsuccessfull requests' do
        it 'should return 404 if Story Item dosent exist' do
          get :show, params: { story_id: story.id.to_s, id: 'storyitemid', api_key: api_key, user_key: api_key }

          expect(response.status).to eq(404)

          expect(JSON.parse(response.body)['errors'])
            .to eq("StoryItem with provided Id storyitemid not found for Story with provided Story Id #{story.id}")
        end
      end
    end

    describe 'POST create' do
      context 'unsuccessfull create requests' do
        it 'should return 400 if required params are not posted' do
          post :create,
               params: {
                 story_id: story.id.to_s,
                 api_key: api_key,
                 user_key: api_key,
                 item: {}
               },
               format: :json

          expect(response).to be_a_bad_request
          expect(JSON.parse(response.body)['errors']).to eq 'Mandatory Parameter story_item missing in request'
        end

        it 'should return error for unknow values for type' do
          post :create,
               params: { story_id: story.id.to_s, api_key: api_key, user_key: api_key, story_item: { type: 'foo' } },
               format: :json

          expect(response).to be_a_bad_request
          expect(JSON.parse(response.body)['errors']).to eq 'Mandatory Parameters Missing: sub_type is missing'
        end

        it 'should return error for unknow values for sub type' do
          post :create,
               params: {
                 story_id: story.id.to_s,
                 api_key: api_key,
                 user_key: api_key,
                 story_item: { type: 'text', sub_type: 'foo', content: { value: 'foo' } }
               },
               format: :json

          expect(response).to be_a_bad_request
          expect(JSON.parse(response.body)['errors'])
            .to eq 'Unsupported Value: sub_type must be one of: heading or rich-text'
        end

        it 'should return error if content and meta is not posted' do
          post :create,
               params: {
                 story_id: story.id.to_s,
                 api_key: api_key,
                 user_key: api_key, story_item: { type: 'text', sub_type: 'heading' }
               }

          expect(response).to be_a_bad_request
          expect(JSON.parse(response.body)['errors']).to eq 'Content value is missing: content must contain value field'
        end
      end

      context 'successfull create request' do
        it 'should return created Story Item' do
          block = { type: 'text', sub_type: 'heading',
                    content: { value: 'sometext' },
                    meta: { title: 'foo' }, position: 100 }

          post :create,
               params: {
                 story_id: story.id.to_s,
                 api_key: api_key,
                 user_key: api_key,
                 story_item: block
               },
               format: :json

          result = JSON.parse(response.body).deep_symbolize_keys
          result.delete(:id)

          expect(result).to eq({ type: 'text', sub_type: 'heading',
                                 content: { value: 'sometext' },
                                 meta: { title: 'foo', is_cover: false },
                                 position: 100, record_id: nil })
        end
      end
    end

    describe 'DELETE story item' do
      context 'successfull deletion' do
        it 'should return 204' do
          delete :destroy,
                 params: {
                   story_id: story.id.to_s,
                   id: story.set_items.last.id.to_s,
                   api_key: api_key,
                   user_key: api_key
                 }

          expect(response.status).to eq 204
        end
      end

      context 'unsuccessfull deletion' do
        it 'should return 404 id story item dosent exist' do
          delete :destroy, params: { story_id: story.id.to_s, id: 'storyitemid', api_key: api_key, user_key: api_key }
          expect(response.status).to eq 404
        end
      end
    end

    describe 'PATCH update' do
      context 'successfull requests' do
        before do
          item = { type: 'text', sub_type: 'heading',
                   content: { value: 'sometext' },
                   meta: { title: 'foo' }, position: 0 }

          patch(:update, params: { story_id: story.id.to_s,
                                   id: story.set_items.first.id.to_s,
                                   api_key: api_key, user_key: api_key, story_item: item })
        end

        it 'returns a 200 http code' do
          expect(response).to be_successful
        end

        it 'should return updated Story Items' do
          response_item = JSON.parse(response.body).deep_symbolize_keys
          first_item = StoryItemSerializer.new(story.set_items.first).as_json

          expect(response_item).to_not eq(first_item)
        end
      end
    end
  end
end
