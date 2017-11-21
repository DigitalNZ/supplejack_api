# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Harvester
    class PartnersController < ApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def create
        if partner_params[:_id].present?
          @partner = Partner.find_or_initialize_by(_id: partner_params[:_id])
          @partner.update_attributes(partner_params)
        else
          @partner = Partner.create(partner_params)
        end
        render json: @partner
      end

      def show
        @partner = Partner.find params[:id]
        render json: @partner
      end

      def index
        @partners = Partner.all
        render json: { partners: @partners }
      end

      def update
        @partner = Partner.find(params[:id])
        @partner.update_attributes(partner_params)
        render json: @partner
      end

      private

      def partner_params
        params.require(:partner).permit(:_id, :name)
      end
    end
  end
end
