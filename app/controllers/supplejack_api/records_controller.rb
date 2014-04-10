require_dependency 'supplejack_api/application_controller'

module SupplejackApi
  class RecordsController < ApplicationController
    
  	respond_to :json, :xml, :rss

    def index
      @search = Search.new(params)
      @search.request_url = request.original_url
      @search.scope = current_user
      
      begin
        if @search.valid?
          respond_with @search, serializer: SearchSerializer
        else
          render request.format.to_sym => {errors: @search.errors}, status: :bad_request
        end
      rescue RSolr::Error::Http => e
        render request.format.to_sym => {:errors => solr_error_message(e) }, :status => :bad_request 
      rescue Sunspot::UnrecognizedFieldError => e
        render request.format.to_sym => {:errors => e.to_s }, :status => :bad_request 
      end
    end

    def show
    end

    def status
	  	render nothing: true
	  end
  end
end
