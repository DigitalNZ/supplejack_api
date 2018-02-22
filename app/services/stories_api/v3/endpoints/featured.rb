# frozen_string_literal: true



module StoriesApi
  module V3
    module Endpoints
      class Featured
        include Helpers
        attr_reader :params, :errors

        def initialize(params = nil); end

        def get
          stories = SupplejackApi::UserSet.featured_sets(4)
          slim = true
          presented_stories = stories.map do |story|
            ::StoriesApi::V3::Presenters::Story.new.call(story, slim)
          end

          create_response(status: 200, payload: presented_stories)
        end
      end
    end
  end
end
