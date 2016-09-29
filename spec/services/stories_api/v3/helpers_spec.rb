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
    end
  end
end
