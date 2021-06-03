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
            create(:story, user: user)
          end

          get :index, params: {api_key: api_key, user_key: api_key, slim: 'false'}
        end

        it 'returns a 200 http code' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns all their stories' do
          expect(response_body.length).to eq(2)
        end

        it 'returns valid stories' do
          UserSet.all.each do |story|
            expect(response_body).to include(StorySerializer.new(story, scope: { slim: false }).as_json)
          end
        end
      end
    end

    describe 'GET admin_index' do
      let(:api_key) { create(:user, role: 'admin').api_key }

      before do
        allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
      end

      context 'unsuccessful request - provided user id does not exist' do
        before { get :admin_index, params: { api_key: api_key, user_id: '1231231231' }}

        it 'returns 404' do
          expect(response).to have_http_status(:not_found)
        end

        it 'includes the error message' do
          expect(response.body).to include(I18n.t('errors.user_with_id_not_found', id: '1231231231'))
        end
      end

      context 'unsuccesful request - not admin' do
        before { get :admin_index, params: { api_key: user.api_key, user_id: user.api_key }}

        it 'returns 403' do
          expect(response).to have_http_status(:forbidden)
        end

        it 'includes the error message' do
          expect(response.body).to include('You need Administrator privileges to perform this request')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).map(&:deep_symbolize_keys) }

        before do
          2.times do
            create(:story, user: user)
          end

          get :admin_index, params: { api_key: api_key, user_id: user.api_key}
        end

        it 'returns a 200 http code' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns all their stories' do
          expect(response_body.length).to eq(2)
        end
      end
    end

    describe 'GET show' do
      context 'when provided story id does not exist' do
        before { get :show, params: { api_key: api_key, id: '1231231231' }}

        it 'returns 404' do
          expect(response).to have_http_status(:not_found)
        end

        it 'includes the error message' do
          expect(response.body).to include(I18n.t('errors.story_not_found', id: '1231231231'))
        end
      end

      context 'when successful' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:story)         { user.user_sets.first }
        let(:story_id)      { story.id.to_s }

        before do
          2.times { create(:story, user: user) }

          get :show, params: { api_key: api_key, id: story_id}
        end

        it 'returns a 200 http code' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns the correct story' do
          expect(response_body[:id]).to eq(story_id)
        end

        it 'returns a valid story' do
          expect(response.body).to eq(StorySerializer.new(story, scope: { slim: false }).to_json)
        end

        it 'creates a user_story_views entry for RequestMetric' do
          expect(SupplejackApi::RequestMetric.count).to eq 1
          expect(SupplejackApi::RequestMetric.first.records.map { |x| x[:record_id] }).to eq story.set_items.map(&:record_id)
          expect(SupplejackApi::RequestMetric.first.records.map { |x| x[:display_collection] }).to eq story.set_items.map { |x| x[:content][:display_collection] }
          expect(SupplejackApi::RequestMetric.first.metric).to eq 'user_story_views'
        end
      end
    end

    describe 'POST create' do
      context 'unsuccessful request - malformed post body' do
        before { post :create, params: {user_key: api_key, api_key: api_key, story: {nope: '1231231231'} }}

        it 'returns 400' do
          expect(response).to have_http_status(:bad_request)
        end

        it 'includes the error message' do
          expect(response.body).to include("Name field can't be blank.")
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:story_name) { 'StoryNameGoesHere' }

        before { post :create, params: {user_key: api_key, api_key: api_key, story: { name: story_name }} }

        it 'returns a 201 http code' do
          expect(response).to have_http_status(:created)
        end

        it 'creates the story' do
          user.reload

          expect(user.user_sets.count).to eq(1)
          expect(user.user_sets.first.name).to eq(story_name)
        end

        it 'returns a valid story' do
          new_story = SupplejackApi::UserSet.find response_body[:id]

          expect(response.body).to eq(StorySerializer.new(new_story, scope: { slim: false }).to_json)
        end
      end
    end

    describe 'DELETE create' do
      context 'unsuccessful request - story not found' do
        before { delete :destroy, params: {api_key: api_key, user_key: api_key, id: '1231231231' }}

        it 'returns 404' do
          expect(response).to have_http_status(:not_found)
        end

        it 'includes the error message' do
          expect(response.body).to include(I18n.t('errors.story_not_found', id: '1231231231'))
        end
      end

      context 'successful request' do
        before do
          story = create(:story, user: user)

          delete :destroy, params: {api_key: api_key, user_key: api_key, id: story.id}
        end

        it 'returns a 204 http code' do
          expect(response).to have_http_status(:no_content)
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
        before { patch :update, params: {api_key: api_key, user_key: api_key, id: '1231231231' }}

        it 'returns 404' do
          expect(response).to have_http_status(:not_found)
        end

        it 'includes the error message' do
          expect(response.body).to include(I18n.t('errors.story_not_found', id: '1231231231'))
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).deep_symbolize_keys }
        let(:name) { 'InsertANameHere' }
        let(:description) { 'InsertADescriptionHere' }
        let(:story) {user.user_sets.create(attributes_for(:story)) }

        before { patch :update, params: { api_key: api_key, user_key: api_key, id: story.id, story: { name: name, description: description } } }

        it 'returns a 200 http code' do
          expect(response).to have_http_status(:ok)
        end

        it 'updates the given Story' do
          updated_story = SupplejackApi::UserSet.find(story.id)

          expect(updated_story.name).to eq(name)
          expect(updated_story.description).to eq(description)
        end

        it 'returns a valid story' do
          expect(response.body).to eq(StorySerializer.new(story.reload, scope: { slim: false }).to_json)
        end
      end
    end
  end
end
