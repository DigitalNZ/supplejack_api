module StoriesApi
  module V3
    module Endpoints
      class Story
        include Helpers

        attr_reader :params

        def initialize(params)
          @params = params
        end

        def get
          story = SupplejackApi::UserSet.custom_find(params[:id])

          unless story.present?
            return {
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            }
          end

          {
            status: 200,
            payload: ::StoriesApi::V3::Presenters::Story.new.call(story)
          }
        end

        def patch
        end

        def delete
          story = SupplejackApi::UserSet.custom_find(params[:id])

          unless story.present?
            return {
              status: 404,
              exception: {
                message: 'Story with given Id was not found'
              }
            }
          end

          story.delete

          {
            status: 204
          }
        end
      end
    end
  end
end
