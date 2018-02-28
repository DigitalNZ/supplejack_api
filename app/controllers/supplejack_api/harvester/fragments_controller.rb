# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class FragmentsController < ApplicationController
      respond_to :json
      before_action :authenticate_harvester!

      def create
        klass = params[:preview] ? SupplejackApi.config.preview_record_class : SupplejackApi.config.record_class
        @record = klass.find(params[:record_id])
        @record.create_or_update_fragment(fragment_params)
        @record.set_status(params[:required_fragments])
        @record.fragments.map(&:save!)

        @record.save!

        # TODO: This is a fix for merged fragments dropping their relationship fields
        # eg attachments. There is most likely a deeper problem with how merged_fragments
        # are built, or how Mongo relationships cascade after they have been saved.
        # DO NOT REMOVE unless you understand this issue and have fixed it.

        @record.save!

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
        record = SupplejackApi.config.record_class.where("fragments.source_id": params[:id])
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
