# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class RecordsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def create
        @record = ::UpdateRecordFromHarvest.new(record_params, params[:preview], nil, params[:required_fragments]).call

        render json: { status: :success, record_id: @record.record_id }
      rescue StandardError => e
        Rails.logger.error "Fail to process record #{@record}: #{e.inspect}"
        render json: {
          status: :failed, exception_class: e.class.to_s,
          message: e.message, backtrace: e.backtrace,
          raw_data: @record.attributes, record_id: @record.try(:record_id)
        }
      end

      def flush
        FlushOldRecordsWorker.perform_async(params[:source_id], params[:job_id])
        head :no_content
      end

      def delete
        # FIXME: This removes record even if it's a preview
        @record = SupplejackApi.config.record_class.where(internal_identifier: params[:id]).first
        @record.update_attribute(:status, 'deleted') if @record.present?

        render json: { status: :success, record_id: params[:id] }
      rescue StandardError => e
        Rails.logger.error "Fail to set deleted status to record #{@record}: #{e.inspect}"

        render json: {
          status: :failed,
          exception_class: e.class.to_s,
          message: e.message,
          backtrace: e.backtrace,
          raw_data: @record.try(:to_json),
          record_id: params[:id]
        }
      end

      def update
        @record = SupplejackApi.config.record_class.custom_find(params[:id], nil, status: :all)
        if params[:record].present? && params[:record][:status].present?
          @record.update_attribute(:status, params[:record][:status])
        end
        respond_with @record
      end

      def show
        @record = SupplejackApi.config.record_class.where(record_id: params[:id]).first

        if @record.present?
          render json: {
            record_id: @record.record_id,
            title: @record.title,
            status: @record.status
          }.to_json
        else
          head :no_content
        end
      end

      def index
        body = "Request must have a search params with one or more of those fields \
                ['record_id', 'fragments.source_id', 'fragments.job_id']"
        return render status: 400, body: body if search_params.blank?

        page = search_options_params[:page].to_i

        @records = SupplejackApi.config.record_class.where(search_params).page(page).per(20).hint(hints)

        if @records.present?
          render json: @records,
                 adapter: :json,
                 each_serializer: ::SupplejackApi::RecordSerializer,
                 include: [:fragments],
                 root: 'records',
                 meta: { page: page, total_pages: @records.total_pages }
        else
          head :no_content
        end
      end

      private

      def record_params
        params.require(:record).to_unsafe_h
      end

      def search_options_params
        params.require(:search_options).permit(:page)
      end

      def search_params
        params.require(:search).permit(['record_id', 'fragments.source_id', 'fragments.job_id'])
      end

      def hints
        indexes = SupplejackApi.config.record_class.collection.indexes.as_json.map { |index| index['key'].keys }.flatten
        search_params.keys.each_with_object({}) do |search_key, object|
          next if search_key == 'record_id'
          next unless indexes.include? search_key
          object[search_key] = 1
        end
      end
    end
  end
end
