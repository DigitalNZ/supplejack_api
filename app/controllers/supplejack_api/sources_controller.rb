# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SourcesController < ActionController::Base

    respond_to :json

    def create
      params[:source].merge!(partner_id: params[:partner_id])
      if params[:source][:_id].present?
        @source = Source.find_or_initialize_by(_id: params[:source][:_id])
        @source.update_attributes(params[:source])
      else
        @source = Source.create(params[:source])
      end

      render json: @source
    end

    def index
      @sources = params[:source].nil? ? Source.all : Source.where(params[:source])
      render json: @sources
    end

    def show
      @source = Source.find(params[:id])
      render json: @source
    end

    def update
      @source = Source.find(params[:id])
      @source.update_attributes(params[:source])
      render json: @source
    end

    def reindex
      @source = Source.find(params[:id])
      Resque.enqueue(IndexSourceWorker, @source.source_id, params[:date])

      render nothing: true
    end

    def link_check_records
      @source = Source.find(params[:id])
      @records = []

      @records += first_two_records(@source.source_id, :oldest).map(&:source_url)
      @records += first_two_records(@source.source_id, :latest).map(&:source_url)

      render json: @records.to_json
    end

    private

    def first_two_records(source_id, direction)
      sort = direction == :latest ? -1 : 1
      records = Record.where("fragments.source_id" => source_id, :status => 'active').sort("fragments.syndication_date" => sort)
      records.limit(2).to_a
    end

  end
end
