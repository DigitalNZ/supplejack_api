# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class FragmentsController < BaseController
      def create
        @record = UpdateRecordFromHarvest.new(fragment_params, params[:preview], params[:record_id], params[:required_fragments]).call

        render json: { status: :success, record_id: @record.record_id }
      rescue StandardError => e
        Rails.logger.error "Fail to process fragment #{@record}: #{e.inspect}"

        render json: {
          status: :failed,
          exception_class: e.class.to_s,
          message: e.message,
          backtrace: e.backtrace,
          raw_data: @record.to_json,
          record_id: @record.record_id
        }
      end

      def destroy
        record = SupplejackApi::Record.where("fragments.source_id": params[:id])
                                      .update_all('$pull' => { fragments: { source_id: params[:id] } })

        render json: { status: :success, record_id: params[:id] }
      rescue StandardError => e
        Rails.logger.error "Fail to set deleted status to fragment id #{params[:id]}"

        render json: {
          status: :failed,
          exception_class: e.class.to_s,
          message: e.message,
          backtrace: e.backtrace,
          raw_data: record.try(:to_json),
          record_id: params[:id]
        }
      end

      private

      def fragment_params
        params.require(:fragment).to_unsafe_h
      end
    end
  end
end
