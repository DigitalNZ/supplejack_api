require_dependency 'supplejack_api/application_controller'

module SupplejackApi
  class RecordsController < ApplicationController
    
  	respond_to :json, :xml, :rss

    def index
    end

    def show
    end

    def status
	  	render nothing: true
	  end
  end
end
