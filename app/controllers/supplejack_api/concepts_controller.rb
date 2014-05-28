# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptsController < ApplicationController
    
    # skip_before_filter :authenticate_user!, :only => [:source, :status]
    # skip_before_filter :verify_limits!,     :only => [:source, :status]

    respond_to :json, :xml, :rss

    def show
      begin
        @concept = Concept.custom_find(params[:id], current_user, params[:search])
        respond_with @concept
      rescue Mongoid::Errors::DocumentNotFound
        render request.format.to_sym => {errors: "Concept with ID #{params[:id]} was not found"}, status: :not_found 
      end
    end

    def default_serializer_options
      { root: false }
    end

  end
end
