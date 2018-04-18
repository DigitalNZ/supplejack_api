# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class ActivitiesController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def index
        render json: SupplejackApi::SiteActivity.order_by(date: :desc),
               root: 'site_activities', each_serializer: ActivitySerializer, adapter: :json
      end
    end
  end
end
