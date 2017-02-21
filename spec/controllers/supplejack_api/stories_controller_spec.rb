# frozen_string_literal: true
module SupplejackApi
  RSpec.describe StoriesController do
    routes { SupplejackApi::Engine.routes }

    let(:user) { create(:user) }
    let(:api_key) { user.api_key }

    describe 'GET index' do

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).map(&:deep_symbolize_keys) }

        before do
          2.times do
            user.user_sets.create(attributes_for(:story))
          end

          get :index, api_key: api_key
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'returns all their stories' do
          expect(response_body.length).to eq(2)
        end

        it 'returns valid stories' do
          expect(response_body.all? {|story| ::StoriesApi::V3::Schemas::Story.call(story).success?}).to eq(true)
        end
      end
    end

    describe 'GET admin_index' do
      let(:api_key) { create(:user, role: 'admin').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
      end

      context 'unsuccessful request - provided user id does not exist' do
        before { get :admin_index, api_key: api_key, user_id: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('User with provided Api Key 1231231231 not found')
        end
      end

      context 'unsuccesful request - not admin' do
        before { get :admin_index, api_key: user.api_key, user_id: user.api_key }

        it 'returns 403' do
          expect(response.status).to eq(403)
        end

        it 'includes the error message' do
          expect(response.body).to include('Administrator privileges')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).map(&:deep_symbolize_keys) }

        before do
          2.times do
            user.user_sets.create(attributes_for(:story))
          end

          get :admin_index, api_key: api_key, user_id: user.api_key
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'returns all their stories' do
          expect(response_body.length).to eq(2)
        end
      end
    end

    describe 'GET show' do
      context 'unsuccessful request - provided story id does not exist' do
        before { get :show, api_key: api_key, id: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('Story with provided Id 1231231231 not found')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:story_id) { user.user_sets.first.id.to_s }

        before do
          2.times do
            user.user_sets.create(attributes_for(:story))
          end

          get :show, api_key: api_key, id: story_id
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'returns the correct story' do
          expect(response_body[:id]).to eq(story_id)
        end

        it 'returns a valid story' do
          expect(::StoriesApi::V3::Schemas::Story.call(response_body).success?).to eq(true)
        end
      end
    end

    describe 'POST create' do
      context 'unsuccessful request - malformed post body' do
        before { post :create, api_key: api_key, story: '1231231231' }

        it 'returns 400' do
          expect(response.status).to eq(400)
        end

        it 'includes the error message' do
          expect(response.body).to include('Mandatory Parameter name missing in request')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:story_name) { 'StoryNameGoesHere' }

        before do
          post :create, api_key: api_key, story: { name: story_name }
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'creates the story' do
          user.reload

          expect(user.user_sets.count).to eq(1)
          expect(user.user_sets.first.name).to eq(story_name)
        end

        it 'returns a valid story' do
          expect(::StoriesApi::V3::Schemas::Story.call(response_body).success?).to eq(true)
        end
      end
    end

    describe 'DELETE create' do
      context 'unsuccessful request - story not found' do
        before { delete :destroy, api_key: api_key, id: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('Story with provided Id 1231231231 not found')
        end
      end

      context 'successful request' do
        before do
          story = user.user_sets.create(attributes_for(:story))

          delete :destroy, api_key: api_key, id: story.id
        end

        it 'returns a 204 http code' do
          expect(response.status).to eq(204)
        end

        it 'deletes the story' do
          user.reload

          expect(user.user_sets.count).to eq(0)
          expect(SupplejackApi::UserSet.count).to eq(0)
        end
      end
    end

    describe 'PATCH update' do
      context 'unsuccessful request - story not found' do
        before { patch :update, api_key: api_key, id: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('Story with provided Id 1231231231 not found')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:name) { 'InsertANameHere' }
        let(:description) { 'InsertADescriptionHere' }
        let(:story) {user.user_sets.create(attributes_for(:story)) }
        let(:story_patch) do
          {
            name: name,
            description: description
          }
        end

        before do
          patch :update, api_key: api_key, id: story.id, story: story_patch
        end

        it 'returns a 200 http code' do
          expect(response.status).to eq(200)
        end

        it 'updates the given Story' do
          updated_story = SupplejackApi::UserSet.find(story.id)

          expect(updated_story.name).to eq(name)
          expect(updated_story.description).to eq(description)
        end

        it 'returns a valid story shape' do
          expect(::StoriesApi::V3::Schemas::Story.call(response_body).success?).to eq(true)
        end
      end
    end
  end
end
