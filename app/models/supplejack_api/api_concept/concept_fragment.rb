# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	module ApiConcept
	  class ConceptFragment < SupplejackApi::Fragment
	  	
	  	embedded_in :concept
	  	
	    delegate :concept_id, to: :concept

	    def self.schema_class
	    	'ConceptSchema'.constantize
	    end
	    
	    build_mongoid_schema

	  end
	end
end
