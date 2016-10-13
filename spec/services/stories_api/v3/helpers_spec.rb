module StoriesApi
  module V3
    RSpec.describe Helpers do
      let(:helpers) do
        class Foo
          include Helpers
        end
        Foo.new
      end

      describe '#current_user' do
        it 'returns the user for the API key in the params' do
          user = create(:user)
          current_user = helpers.current_user(api_key: user.api_key)

          expect(current_user.api_key).to eq(user.api_key)
        end
      end

      describe '#create_error' do
        it 'returns an error for the Error class and options passed' do
          expect(helpers.create_error('StoryNotFound', { id: 1 })).to eq(
            status: 404,
            exception: {
              message: 'Story with provided Id 1 not found'
            }
          )
        end
      end

      describe '#create_response' do
        it 'returns a response hash with status and payload' do
          expect(helpers.create_response(status: 200, payload: 'Payload')).to eq(
            status: 200,
            payload: 'Payload'
          )
        end

        it 'does not include a payload if one is not provided' do
          expect(helpers.create_response(status: 200)).to eq(
            status: 200,
          )
        end

        it 'includes the payload if it is an empty array' do
          expect(helpers.create_response(status: 200, payload: [])).to eq(
            status: 200,
            payload: []
          )
        end
      end
    end
  end
end
