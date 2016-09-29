module SupplejackApi
  RSpec.describe StoriesController do
    routes { SupplejackApi::Engine.routes }

    let(:user) { create(:user) }
    let(:api_key) { user.api_key }

    describe 'GET index' do
      context 'unsuccessful request - provided user id does not exist' do
        before { get :index, api_key: api_key, user: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('Id was not found')
        end
      end

      context 'successful request' do
        let(:response_body) { JSON.parse(response.body).map(&:deep_symbolize_keys) }

        before do
          2.times do
            user.user_sets.create(attributes_for(:story))
          end

          get :index, api_key: api_key, user: api_key
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

    describe 'GET show' do
      context 'unsuccessful request - provided story id does not exist' do
        before { get :show, api_key: api_key, id: '1231231231' }

        it 'returns 404' do
          expect(response.status).to eq(404)
        end

        it 'includes the error message' do
          expect(response.body).to include('Id was not found')
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
  end
end
