# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class ActivitiesController < BaseController
      def index
        render json: SupplejackApi::SiteActivity.order_by(date: :desc),
               root: 'site_activities', each_serializer: ActivitySerializer, adapter: :json
      end
    end
  end
end
