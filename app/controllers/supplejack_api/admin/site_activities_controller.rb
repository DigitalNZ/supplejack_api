# frozen_string_literal: true



module SupplejackApi
  module Admin
    class SiteActivitiesController < BaseController
      respond_to :html
      respond_to :csv, only: :index

      def index
        @site_activities = SupplejackApi::SiteActivity.sortable(order: params[:order], page: params[:page])
                                                      .order_by(date: :desc)
      end
    end
  end
end
