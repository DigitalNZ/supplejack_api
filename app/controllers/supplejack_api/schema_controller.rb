# frozen_string_literal: true

module SupplejackApi
  class SchemaController < ApplicationController
    skip_before_action :authenticate_user!, raise: false
    respond_to :json, :xml

    def show
      @schema_fields = Concept.build_context(ConceptSchema.model_fields.keys)
      respond_with @schema_fields
    end
  end
end
