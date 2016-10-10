# frozen_string_literal: true
module StoriesApi
  module V3
    RSpec.describe Errors do
      it 'should return error for given code and message' do
        object = Errors::Base.new(403, 'Forbidden Request')

        expect(object.error).to eq(status: 403,
                                   exception: { message: 'Forbidden Request' })
      end

      it 'should return error for user not found' do
        object = Errors::UserNotFound.new(id: 101)

        expect(object.error).to eq(status: 404,
                                   exception: { message: 'User with provided Api Key 101 not found' })
      end

      it 'should return error for story not found' do
        object = Errors::StoryNotFound.new(id: 202)

        expect(object.error).to eq(status: 404,
                                   exception: { message: 'Story with provided Id 202 not found' })
      end

      it 'should return error for mising mandatory parameter' do
        object = Errors::MandatoryParamMissing.new(param: :fake_field)

        expect(object.error).to eq(status: 400,
                                   exception: { message: 'Mandatory Parameter fake_field missing in request' })
      end

      it 'should return error for unsopported field value' do
        object = Errors::UnsupportedFieldType.new(param: :fake_field, value: 'unspported_value')

        expect(object.error).to eq(status: 415,
                                   exception: {
                                     message: 'Unsupported value unspported_value for parameter fake_field'
                                   })
      end

      it 'should return error code 400 for missing param error for scheme validation' do
        validation_error = { content: { id: ['id is missing'] } }
        object = Errors::SchemaValidationError.new(errors: validation_error)

        expect(object.error).to eq(status: 400,
                                   exception: { message: 'Bad Request. id is missing in content' })
      end

      it 'should return error code 400 for scheme validation' do
        validation_error = { content: { id: ['id must be integer'] } }
        object = Errors::SchemaValidationError.new(errors: validation_error)

        expect(object.error).to eq(status: 400,
                                   exception: { message: 'Bad Request. id must be integer in content' })
      end

      it 'should return error for story item not found' do
        object = Errors::StoryItemNotFound.new(item_id: 'storyitemid', story_id: 'storyid')

        expect(object.error).to eq(status: 404,
                                   exception: {
                                     message: 'StoryItem with provided Id storyitemid not found for Story with provided Story Id storyid'
                                   })
      end      
    end
  end
end
