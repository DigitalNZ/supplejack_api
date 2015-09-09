# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
        SupplejackApi::Record.where(:"fragments.source_id" => params[:id])
                             .update_all({ "$pull" => {fragments: {source_id: params[:id]}} })
        respond_with
      end
  	end
  end
end
