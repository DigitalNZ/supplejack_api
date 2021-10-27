# frozen_string_literal: true

module SupplejackApi
  # rubocop:disable Metrics/ClassLength
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
      @search.request_url = request.original_url
      @search.scope = current_user

      if @search.valid?
        respond_to do |format|
          format.json do
            render json: @search, serializer: self.class.search_serializer_class, record_fields: available_fields,
                   record_includes: available_fields, root: 'search', adapter: :json,
                   callback: params['jsonp']
          end
          format.xml do
            options = { serializer: self.class.search_serializer_class, record_includes: available_fields,
                        record_fields: available_fields, request_format: 'xml', root: 'search' }
            serializable_resource = ActiveModelSerializers::SerializableResource.new(@search, options)
            # The double as_json is required to render the inner json object as json as well as the exterior object

            render xml: serializable_resource.as_json.as_json.to_xml(root: 'search')
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
      @record = SupplejackApi::Record.custom_find(params[:id], current_user, search_params)

      respond_to do |format|
        format.json do
          render json: @record, serializer: self.class.record_serializer_class,
                 fields: available_fields, root: 'record',
                 include: available_fields, adapter: :json, callback: params['jsonp']
        end
        format.xml do
          options = { serializer: self.class.record_serializer_class,
                      fields: available_fields, include: available_fields, root: 'record' }
          serializable_resource = ActiveModelSerializers::SerializableResource.new(@record, options)
          render xml: serializable_resource.as_json.to_xml(root: 'record')
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

      mlt = record.more_like_this do
        fields(*mlt_fields)
        minimum_term_frequency(params[:frequency] || 1)
      end

      respond_with mlt.results, each_serializer: self.class.mlt_serializer_class, root: 'records', adapter: :json
    end

    # This options are merged with the serializer options. Which will allow the serializer
    # to know which fields to render for a specific request
    def default_serializer_options
      default_options = {}
      @search ||= SupplejackApi::RecordSearch.new(all_params)
      default_options[:fields] = @search.field_list if @search.field_list.present?
      default_options[:groups] = @search.group_list if @search.group_list.present?
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

    def mlt_fields
      return [] unless params[:mlt_fields]

      params[:mlt_fields].split(',').map { |field| field.strip.to_sym }
    end

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
  # rubocop:enable Metrics/ClassLength
end
