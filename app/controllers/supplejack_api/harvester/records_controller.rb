# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class RecordsController < SupplejackApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def create
        @record = ::UpdateRecordFromHarvest.new(record_params, params[:preview], nil, params[:required_fragments]).call

        # klass = params[:preview] ? SupplejackApi.config.preview_record_class : SupplejackApi.config.record_class
        # @record = klass.find_or_initialize_by_identifier(record_params)
        #
        # # In the long run this condition shouldn't be here.
        # # It's because the data_handler interfaces are using update_from_harvest,
        # # and clear_attributes that I can't factor it back in.
        #
        # if params[:record][:priority] && params[:record][:priority].to_i.nonzero?
        #   @record.create_or_update_fragment(record_params)
        # else
        #   @record.clear_attributes
        #   @record.update_from_harvest(record_params)
        # end
        #
        # @record.set_status(params[:required_fragments])
        # @record.fragments.map(&:save!)
        #
        # @record.save!
        #
        # # TODO: This is a fix for merged fragments dropping their relationship fields
        # # eg attachments. There is most likely a deeper problem with how merged_fragments
        # # are built, or how Mongo relationships cascade after they have been saved.
        # # DO NOT REMOVE unless you understand this issue and have fixed it.
        #
        # @record.save!
        #
        # @record.unset_null_fields

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
