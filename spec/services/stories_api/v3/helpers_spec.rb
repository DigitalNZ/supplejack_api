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

      describe '#create_exception' do
        it 'returns an exception hash with a status and message' do
          expect(helpers.create_exception(status: 400, message: 'Error message')).to eq(
            status: 400,
            exception: {
              message: 'Error message'
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
      end
    end
  end
end
