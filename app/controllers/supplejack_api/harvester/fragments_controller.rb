# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
