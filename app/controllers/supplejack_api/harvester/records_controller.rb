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
        klass = params[:preview] ? SupplejackApi::PreviewRecord : SupplejackApi::Record
        @record = klass.find_or_initialize_by_identifier(params[:record])
        @record.set_status(params[:required_fragments])
        @record.landing_url = params[:record].delete(:landing_url)
        @record.create_or_update_fragment(params[:record])

        @record.save
        @record.unset_null_fields
        render json: {record_id: @record.record_id}
      end

      def flush
        Resque.enqueue(FlushOldRecordsWorker, params[:source_id], params[:job_id])
        render nothing: true, status: 204
      end

      def delete
        @record = Record.where(internal_identifier: params[:id]).first
        @record.update_attribute(:status, "deleted") if @record.present?
        render nothing: true, status: 204
      end

      def update
        @record = Record.custom_find(params[:id],nil, {status: :all})
        if params[:record].present? and params[:record][:status].present?
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