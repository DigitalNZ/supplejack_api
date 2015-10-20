# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SetItemsController < ApplicationController
    include SupplejackApi::Concerns::SetItemsControllerMetrics

    before_filter :find_user_set

    respond_to :json

    def create
      @set_item = @user_set.set_items.build(record_params)
      @user_set.save
      respond_with @user_set, @set_item
    end

    def destroy
      @set_item = @user_set.set_items.find_by_record_id(params[:id])
      if @set_item
        @set_item.destroy
        @user_set.save
        respond_with @user_set, @set_item
      else
        render json: {errors: "The record with id: #{params[:id]} was not found."}, status: :not_found
      end
    end

    def record_params
      params.require(:record).permit(:record_id)
    end
  end
end
