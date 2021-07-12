# frozen_string_literal: true

module SupplejackApi
  module Stories
    class FeaturedController < SupplejackApplicationController
      def index
        render json: SupplejackApi::UserSet.featured_sets(4),
               each_serializer: StorySerializer,
               root: false, scope: { slim: true }
      end
    end
  end
end
