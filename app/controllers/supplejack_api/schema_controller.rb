# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class SchemaController < ApplicationController
    skip_before_filter :authenticate_user!
    respond_to :json, :xml

		def show
      @schema_fields = Concept.build_context(ConceptSchema.model_fields.keys)
      respond_with @schema_fields
		end
	end
end