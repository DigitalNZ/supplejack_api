module StoriesApi
  module V3
    module Endpoints
      RSpec.describe Stories do
        describe '#get' do
          it 'returns 404 if the provided user id does not exist' do
            response = Stories.new({user: '1231892312hj3k12j3'}).get

            expect(response).to eql({
              status: 404,
              exception: {
                message: 'User with provided Id not found'
              }
            })
          end

          context '200 response' do

          end
        end
      end
    end
  end
end
