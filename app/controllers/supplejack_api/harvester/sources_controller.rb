# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class SourcesController < BaseController
      def create
        if source_params[:_id].present?
          @source = Source.find_or_initialize_by(_id: source_params[:_id])
          @source.update(source_params)
        else
          @source = Source.create(source_params)
        end

        render json: @source
      end

      def index
        @sources = params[:source].blank? ? Source.all : Source.where(source_params)
        @sources = @sources.order_by(params[:order_by] => 'desc') if params[:order_by].present?
        @sources = @sources.limit(params[:limit]) if params[:limit].present?

        render json: @sources
      end

      def show
        @source = Source.find(params[:id])
        render json: @source
      end

      def update
        @source = Source.find(params[:id])
        source_params['status_updated_at'] = Time.now.utc.to_datetime if source_params['status']
        @source.update(source_params)
        render json: @source
      end

      def reindex
        @source = Source.find(params[:id])
        IndexSourceWorker.perform_async(@source.source_id, params[:date])

        head :created
      end

      # Returns 4 random records for the source
      def link_check_records
        source = Source.find(params[:id])
        records = source.random_records(4).map(&:landing_url)
        render json: records.to_json
      end

      private

      def source_params
        @source_params ||= begin
          source_params = params.require(:source).permit(:name, :_id, :id, :source_id, :status, :status_updated_by).to_h
          partner_params = params.permit(:partner_id).to_h
          source_params.merge(partner_params)
        end
      end
    end
  end
end
