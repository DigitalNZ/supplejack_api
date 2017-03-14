# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module StoriesApi
  module V3
    module Endpoints
      class Stories
        include Helpers

        attr_reader :params, :errors, :user

        def initialize(params)
          @params = params
          @user = current_user(params)
        end

        def get
          return create_error('UserNotFound', id: params[:api_key]) unless user.present?

          if params[:slim].present? && params[:slim]
            presented_stories = user.user_sets.order_by(updated_at: 'desc').map do |user_set|
              ::StoriesApi::V3::Presenters::Story.new.call(user_set, true)
            end
          else
            presented_stories = user.user_sets.map(&::StoriesApi::V3::Presenters::Story)
          end

          create_response(status: 200, payload: presented_stories)
        end

        def post
          story = params[:story]

          return create_error('MandatoryParamMissing',
                              param: :name) unless story.is_a?(Hash) && story[:name].present?

          new_story = user.user_sets.create(name: story[:name])

          create_response(status: 200, payload: ::StoriesApi::V3::Presenters::Story.new.call(new_story))
        end
      end
    end
  end
end
