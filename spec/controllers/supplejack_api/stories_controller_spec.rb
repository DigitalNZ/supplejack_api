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
          expect(response.body).to include('Id not found')
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
  end
end
