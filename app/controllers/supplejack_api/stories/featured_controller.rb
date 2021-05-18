# frozen_string_literal: true

module SupplejackApi
  module Stories
    class FeaturedController < SupplejackApplicationController
      include Concerns::Stories

      def index
        render_response(:featured)
      end
    end
  end
end
