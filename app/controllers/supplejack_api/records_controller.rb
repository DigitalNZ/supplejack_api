# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordsController < ApplicationController
    include SupplejackApi::Concerns::RecordsControllerMetrics

    skip_before_action :authenticate_user!, only: %i[source status]
    skip_before_action :verify_authenticity_token
    before_action :set_concept_param, only: :index
    respond_to :json, :xml

    def index
      @search = SupplejackApi::RecordSearch.new(params)
      @search.request_url = request.original_url
      @search.scope = current_user

      begin
        if @search.valid?
          respond_to do |format|
            format.json do
              render json: @search, serializer: SearchSerializer, record_fields: available_fields,
                     record_includes: available_fields, root: 'search', adapter: :json,
                     callback: params['jsonp']
            end
            format.xml do
              options = { serializer: SearchSerializer, record_fields: available_fields }
              serializable_resource = ActiveModelSerializers::SerializableResource.new(@search, options)

              # The double as_json is required to render the inner json object as json as well as the exterior object
              render xml: serializable_resource.as_json.as_json.to_xml(root: 'search')
            end
          end
        else
          render request.format.to_sym => { errors: @search.errors }, status: :bad_request
        end
      rescue RSolr::Error::Http => e
        render request.format.to_sym => { errors: solr_error_message(e) }, status: :bad_request
      rescue Sunspot::UnrecognizedFieldError => e
        render request.format.to_sym => { errors: e.to_s }, status: :bad_request
      end
    end

    def status
      render nothing: true
    end

    def show
      @record = SupplejackApi.config.record_class.custom_find(params[:id], current_user, search_params)
      respond_to do |format|
        format.json do
          render json: @record, serializer: RecordSerializer, fields: available_fields, root: 'record',
                 include: available_fields, adapter: :json, callback: params['jsonp']
        end
        format.xml do
          options = { serializer: RecordSerializer, fields: available_fields }
          serializable_resource = ActiveModelSerializers::SerializableResource.new(@record, options)
          render xml: serializable_resource.as_json.to_xml(root: 'record')
        end
      end
    rescue Mongoid::Errors::DocumentNotFound
      render request.format.to_sym => { errors: "Record with ID #{params[:id]} was not found" }, status: :not_found
    end

    def multiple
      @records = SupplejackApi.config.record_class.find_multiple(params[:record_ids])
      respond_with @records, each_serializer: RecordSerializer, root: 'records', adapter: :json
    end

    # This options are merged with the serializer options. Which will allow the serializer
    # to know which fields to render for a specific request
    #
    def default_serializer_options
      default_options = {}
      @search ||= SupplejackApi::RecordSearch.new(params)
      default_options[:fields] = @search.field_list if @search.field_list.present?
      default_options[:groups] = @search.group_list if @search.group_list.present?
      default_options
    end

    private

    def set_concept_param
      if params[:concept_id].present?
        params[:and] ||= {}
        params[:and][:concept_id] = params[:concept_id]
      end
    end

    def available_fields
      DetermineAvailableFields.new(default_serializer_options).call
    end

    def search_params
      # Allowing unsafe params here becuase the requests are read only.
      # Also the search params are complicated, and have many permutations (AND, OR result in search
      # params which would otherwise not be nested).  It's easiest to convert them all to an unsafe
      # hash and work with them that way.
      params[:search]&.to_unsafe_h
    end
  end
end
