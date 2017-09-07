# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Harvester
    class RecordsController < ActionController::Base
      respond_to :json
      def create
        klass = params[:preview] ? PreviewRecord : Record
        @record = klass.find_or_initialize_by_identifier(params[:record])

        # In the long run this condition shouldn't be here.
        # It's because the data_handler interfaces are using update_from_harvest,
        # and clear_attributes that I can't factor it back in.
        if params[:record][:priority] && params[:record][:priority].to_i.nonzero?
          @record.create_or_update_fragment(params[:record])
        else
          @record.clear_attributes
          @record.update_from_harvest(params[:record])
        end

        @record.set_status(params[:required_fragments])
        @record.fragments.map(&:save!)
        @record.save!
        @record.unset_null_fields

        render json: { status: :success, record_id: @record.record_id }
      rescue StandardError => e
        Rails.logger.error "Fail to process record #{@record}: #{e.inspect}"
        render json: {
          status: :failed,
          exception_class: e.class.to_s,
          message: e.message,
          backtrace: e.backtrace,
          raw_data: @record.try(:to_json),
          record_id: @record.try(:record_id)
        }
      end

      def flush
        FlushOldRecordsWorker.perform_async(params[:source_id], params[:job_id])
        render nothing: true, status: 204
      end

      def delete
        # FIXME: This removes record even if it's a preview
        @record = Record.where(internal_identifier: params[:id]).first
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
        @record = Record.custom_find(params[:id], nil, status: :all)
        if params[:record].present? && params[:record][:status].present?
          @record.update_attribute(:status, params[:record][:status])
        end
        respond_with @record
      end

      def show
        @record = Record.where(record_id: params[:id]).first

        if @record.present?
          render json: {
            record_id: @record.record_id,
            title: @record.title,
            status: @record.status
          }.to_json
        else
          render nothing: true, status: 204
        end
      end
    end
  end
end
