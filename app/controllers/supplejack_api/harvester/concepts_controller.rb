# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class ConceptsController < BaseController
      def create
        if params[:preview]
          klass = SupplejackApi::PreviewRecord
          attribute = :record_id
        else
          klass = Concept
          attribute = :concept_id
        end

        @concept = klass.find_or_initialize_by_identifier(params[:concept])
        @concept.set_status(params[:required_fragments])
        @concept.create_or_update_fragment(params[:concept])
        @concept.save
        @concept.unset_null_fields

        render json: { attribute => @concept.concept_id }
      end

      def update
        @concept = Concept.custom_find(params[:id], nil, status: :all)
        if params[:concept].present? && params[:concept][:status].present?
          @concept.update_attribute(:status, params[:concept][:status])
        end
        respond_with @concept
      end
    end
  end
end
