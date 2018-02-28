# frozen_string_literal: true

module SupplejackApi
  class ConceptsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:source], raise: false
    # skip_before_action :verify_limits!,     only: [:source]  This devise method doesn't work with rails 5 upgrade.
    # We need find out how this works with the version of devise we are up to.

    respond_to :json, :xml, :rss

    def index
      @search = ConceptSearch.new(params)
      @search.request_url = request.original_url
      @search.scope = current_user

      begin
        if @search.valid?
          respond_with @search, serializer: SearchSerializer, root: 'concept_search', adapter: :json
        else
          render request.format.to_sym => { errors: @search.errors }, status: :bad_request
        end
      rescue RSolr::Error::Http => e
        render request.format.to_sym => { errors: solr_error_message(e) }, status: :bad_request
      rescue Sunspot::UnrecognizedFieldError => e
        render request.format.to_sym => { errors: e.to_s }, status: :bad_request
      end
    end

    def show
      @concept = SupplejackApi::Concept.custom_find(params[:id], current_user, params[:search])
      respond_with @concept, serializer: ConceptSerializer, include: params[:fields].to_s,
                             inline_context: params[:inline_context]
    rescue Mongoid::Errors::DocumentNotFound
      render request.format.to_sym => { errors: "Concept with ID #{params[:id]} was not found" }, status: :not_found
    end
  end
end
