# frozen_string_literal: true

module SupplejackApi
  class RecordsController < SupplejackApplicationController
    include SupplejackApi::Concerns::RecordsControllerMetrics
    include ActionController::RequestForgeryProtection

    # This module is used for RSS templates
    include ActionView::Rendering

    protect_from_forgery except: %i[index show]
    skip_before_action :authenticate_user!, only: %i[source status], raise: false
    before_action :set_concept_param, only: :index
    respond_to :json, :xml, :rss

    def index
      @search = SupplejackApi::RecordSearch.new(all_params)
      @search.scope = current_user

      if @search.valid?
        respond_to do |format|
          format.json do
            render_json_with json: @search, serializer: self.class.search_serializer_class,
                             record_fields: available_fields, record_includes: available_fields,
                             record_url: request.original_url, root: 'search', adapter: :json, callback: params['jsonp']
          end
          format.xml do
            options = {
              serializer: self.class.search_serializer_class, record_includes: available_fields,
              record_url: request.original_url, record_fields: available_fields, request_format: 'xml', root: 'search'
            }

            render_xml_with(@search, options, 'search')
          end
          format.rss { respond_with @search }
        end
      else
        render request.format.to_sym => { errors: @search.errors }, status: :bad_request
      end
    end

    def status
      render nothing: true
    end

    def show
      @record = SupplejackApi::Record.custom_find(params[:id], current_user, next_previous_search_params)

      respond_to do |format|
        format.json do
          render_json_with json: @record, serializer: self.class.record_serializer_class,
                           fields: available_fields, root: 'record',
                           include: available_fields, adapter: :json, callback: params['jsonp']
        end
        format.xml do
          options = { serializer: self.class.record_serializer_class, root: 'record',
                      fields: available_fields, include: available_fields }

          render_xml_with(@record, options, 'record')
        end
        format.rss { respond_with @record }
      end
    end

    def multiple
      @records = SupplejackApi::Record.find_multiple(params[:record_ids])

      respond_with @records, each_serializer: self.class.record_serializer_class, root: 'records', adapter: :json
    end

    def more_like_this
      record = SupplejackApi::Record.custom_find(params[:record_id])
      search = SupplejackApi::MoreLikeThisSearch.new(record, current_user&.role, all_params)

      render(
        json: search,
        serializer: self.class.mlt_serializer_class,
        record_fields: available_fields,
        record_url: request.original_url,
        record_includes: available_fields,
        root: 'more_like_this',
        adapter: :json,
        callback: params['jsonp']
      )
    end

    # This options are merged with the serializer options. Which will allow the serializer
    # to know which fields to render for a specific request
    def default_serializer_options
      default_options = {}
      @search ||= SupplejackApi::RecordSearch.new(all_params)
      default_options[:fields] = @search.options.fields if @search.options.fields.present?
      default_options[:groups] = @search.options.group_list if @search.options.group_list.present?
      default_options
    end

    def self.search_serializer_class
      SearchSerializer
    end

    def self.mlt_serializer_class
      MltSerializer
    end

    def self.record_serializer_class
      RecordSerializer
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

    def next_previous_search_params
      params.fetch(:search, {}).permit([:page, :per_page, :record_type, :text, { and: {} }, { or: {} }]).to_unsafe_h
    end

    def all_params
      params.to_unsafe_h
    end

    # this is a method override due to the ActionController::API module
    # not being able to render templates
    # further read up on the issue can be found here:
    # https://github.com/rails/rails/issues/27211#issuecomment-264392054
    def render_to_body(options)
      _render_to_body_with_renderer(options) || super
    end
  end
end
