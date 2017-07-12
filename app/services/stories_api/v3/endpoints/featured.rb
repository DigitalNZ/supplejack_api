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
      class Featured
        include Helpers

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
