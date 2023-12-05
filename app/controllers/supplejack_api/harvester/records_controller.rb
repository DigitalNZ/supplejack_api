# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class RecordsController < BaseController
      def create
        @record = UpdateRecordFromHarvest.new(record_params, params[:preview], nil, params[:required_fragments]).call

        render json: { status: :success, record_id: @record.record_id }
      rescue StandardError => e
        Rails.logger.error "Fail to process record #{@record&.record_id}: #{e.inspect}"
        render json: {
          status: :failed, exception_class: e.class.to_s,
          message: e.message, backtrace: e.backtrace,
          raw_data: @record&.attributes, record_id: @record&.record_id
        }
      end

      def create_batch
        records = params[:records].each_with_object([]) do |record, array|
          r = UpdateRecordFromHarvest.new(record['fields'].to_unsafe_h, false, nil, record['required_fragments']).call
          array.push({ status: 'success', record_id: r.record_id })

        rescue StandardError => e
          array.push({ status: 'failed', exception_class: e.class.to_s,
                       message: e.message, backtrace: e.backtrace,
                       raw_data: r&.attributes, record_id: r&.record_id })
        end

        render json: records
      end

      def flush
        FlushOldRecordsWorker.perform_async(params[:source_id], params[:job_id])
        head :no_content
      end

      def delete
        # FIXME: This removes record even if it's a preview
        @record = SupplejackApi::Record.where(internal_identifier: params[:id]).first
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
        @record = SupplejackApi::Record.custom_find(params[:id], nil, status: :all)
        if params[:record].present? && params[:record][:status].present?
          @record.update(status: params[:record][:status])
        end
        respond_with @record
      end

      def show
        @record = SupplejackApi::Record.where(record_id: params[:id]).first

        if @record.present?
          render json: @record,
                 serializer: self.class.record_serializer_class
        else
          head :no_content
        end
      end

      def index
        body = "Request must have a search params with one or more of those fields \
                ['record_id', 'fragments.source_id', 'fragments.job_id']"
        return render status: :bad_request, body: body if search_params.blank?

        page = search_options_params[:page].to_i

        @records = SupplejackApi::Record
                   .where(search_params.to_hash)
                   .page(page).per(20).hint(hints)

        if @records.present?
          render json: @records,
                 adapter: :json,
                 each_serializer: self.class.record_serializer_class,
                 include: self.class.record_serializer_includes,
                 root: 'records',
                 meta: { page: page, total_pages: @records.total_pages }
        else
          head :no_content
        end
      end

      def self.record_serializer_class
        RecordSerializer
      end

      def self.record_serializer_includes
        [:fragments]
      end

      private

      def record_params
        params.require(:record).to_unsafe_h
      end

      def search_options_params
        params.require(:search_options).permit(:page)
      end

      def search_params
        params.require(:search).permit(['record_id', 'fragments.source_id', 'fragments.job_id', 'status'])
      end

      def hints
        indexes = SupplejackApi::Record.collection.indexes.as_json.map { |index| index['key'].keys }.flatten
        search_params.keys.each_with_object({}) do |search_key, object|
          next if %w[record_id status].include? search_key
          next unless indexes.include? search_key

          object[search_key] = 1
        end
      end
    end
  end
end
