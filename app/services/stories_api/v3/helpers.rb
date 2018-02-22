# frozen_string_literal: true



module StoriesApi
  module V3
    module Helpers
      def current_user(params)
        @current_user ||= SupplejackApi::User.find_by_api_key(params[:user_key])
      end

      def create_error(error = nil, options = {})
        "StoriesApi::V3::Errors::#{error}".constantize.new(options).error
      end

      def create_response(status: nil, payload: nil)
        response = { status: status }
        response[:payload] = payload unless payload.nil?

        response
      end

      def first_suitable_image(story)
        item_with_image = story.set_items.sort_by(&:position).detect do |item|
          item.content.present? && (item.type == 'embed') &&
            (item.sub_type == 'record') && item.content[:image_url].present?
        end

        item_with_image.content[:image_url] unless item_with_image.nil?
      end
    end
  end
end
