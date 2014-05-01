module SupplejackApi
  class PartnersController < ActionController::Base
    respond_to :json

    def create
      if params[:partner][:_id].present?
        @partner = Partner.find_or_initialize_by(_id: params[:partner][:_id])
        @partner.update_attributes(params[:partner])
      else
        @partner = Partner.create(params[:partner])
      end
      render json: @partner
    end

    def show
      @partner = Partner.find params[:id]
      render json: @partner
    end

    def index
      @partners = Partner.all
      render json: @partners
    end

    def update
      @partner = Partner.find(params[:id])
      @partner.update_attributes(params[:partner])
      render json: @partner
    end
  end
end
