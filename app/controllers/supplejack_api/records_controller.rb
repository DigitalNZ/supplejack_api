# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordsController < ApplicationController
    
    skip_before_action :authenticate_user!, :only => [:source, :status]
    respond_to :json, :xml, :rss

    def index
      @search = SupplejackApi::RecordSearch.new(params)
      @search.request_url = request.original_url
      @search.scope = current_user
      
      begin
        if @search.valid?
          respond_with @search, serializer: RecordSearchSerializer
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
      begin
        @record = SupplejackApi::Record.custom_find(params[:id], current_user, params[:search])
        respond_with @record, serializer: RecordSerializer
      rescue Mongoid::Errors::DocumentNotFound
        render request.format.to_sym => { errors: "Record with ID #{params[:id]} was not found" }, status: :not_found
      end
    end

    def multiple
      @records = Record.find_multiple(params[:record_ids])
      respond_with @records
    end

    def source
      begin
        @record = SupplejackApi::Record.custom_find(params[:id])

        # TODO: KEEP IN ENGINE?
        # track_google_analytics!({content_partner:  @record.display_content_partner, collection: @record.display_collection, :id => @record.record_id})

        @record.link_check if @record.landing_url.present?

        SupplejackApi::SourceActivity.increment
        redirect_to @record.redirect_url
      rescue Mongoid::Errors::DocumentNotFound
        render request.format.to_sym => {:errors => "Record with ID #{params[:id]} was not found" }, :status => :not_found 
      end
    end

    # This options are merged with the serializer options. Which will allow the serializer
    # to know which fields to render for a specific request
    #
    def default_serializer_options
      default_options = {}
      @search ||= SupplejackApi::RecordSearch.new(params)
      default_options.merge!({:fields => @search.field_list}) if @search.field_list.present?
      default_options.merge!({:groups => @search.group_list}) if @search.group_list.present?
      default_options
    end
  end
end
