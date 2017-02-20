# frozen_string_literal: true
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
      params[:source][:partner_id] = params[:partner_id]
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
      IndexSourceWorker.perform_async(@source.source_id, params[:date])

      render nothing: true
    end

    def link_check_records
      @source = Source.find(params[:id])
      source_urls = @source.random_records(4).map(&:landing_url)

      render json: source_urls
    end

    private

    def first_two_records(source_id, direction)
      sort = direction == :latest ? -1 : 1
      records = Record.where('fragments.source_id' => source_id, :status => 'active')
                      .sort('fragments.syndication_date' => sort)
      records.limit(2).to_a
    end
  end
end
