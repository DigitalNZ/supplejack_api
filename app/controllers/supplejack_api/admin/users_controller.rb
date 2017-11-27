# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Admin
    class UsersController < BaseController
      layout 'supplejack_api/application'

      respond_to :html
      respond_to :csv, only: :index

      def index
        @users = User.sortable(order: params[:order] || :daily_requests_desc, page: params[:page])
      end

      def show
        @user = User.find(params[:id])
        @api_requests = LazyHighCharts::HighChart.new('graph') do |f|
          f.title(text: 'API requests/day for the last 90 days')
          f.series(name: 'API Requests',
                   data: @user.requests_per_day(90),
                   pointStart: 89.days.ago,
                   pointInterval: 1.day)
          f.xAxis(type: :datetime)
          f.yAxis(title: { text: 'Number of Requests' }, min: 0)
        end
      end

      def edit
        @user = User.find(params[:id])
      end

      def update
        @user = User.find(params[:id])

        if @user.update_attributes(user_params)
          redirect_to admin_users_path
        else
          render :edit
        end
      end

      private

      def user_params
        params.require(:user).permit(:max_requests).to_h
      end
    end
  end
end
