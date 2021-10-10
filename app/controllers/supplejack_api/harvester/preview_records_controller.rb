# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class PreviewRecordsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def index
        @records = SupplejackApi::PreviewRecord.where(search_params)

        if @records.present?
          render json: @records, each_serializer: ::SupplejackApi::PreviewRecordSerializer, include: :fragments
        else
          head :no_content
        end
      end

      private

      def search_params
        params.require(:search).to_unsafe_h
      end
    end
  end
end
