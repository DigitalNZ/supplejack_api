module SupplejackApi
  module Harvester
  	class FragmentsController < ActionController::Base
  
  		respond_to :json
  
      def create
        klass = params[:preview] ? PreviewRecord : Record
        @record = klass.find(params[:record_id])
        @record.create_or_update_fragment(params[:fragment])
        @record.set_status(params[:required_fragments])
        @record.save
        render json: {record_id: @record.record_id }
      end
  
      def destroy
        Record.where(:"fragments.source_id" => params[:id]).update_all({ "$pull" => {fragments: {source_id: params[:id]}} })
        respond_with
      end
  	end
  end
end
