# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer
  	attributes :@id, :@type, :label, :status, :concept_type

  	private

    def attributes
	  	data = {}
	  	data['@context'] = {
	  		label: 'http://www.w3.org/2004/02/skos/core#prefLabel',
		    foaf: 'http://xmlns.com/foaf/0.1/',
		    name: 'foaf:name',
		    rdaGr2: 'http://rdvocab.info/ElementsGr2/',
		    dateOfBirth: 'rdaGr2:dateOfBirth',
		    dateOfDeath: 'rdaGr2:dateOfDeath',
		    placeOfBirth: 'rdaGr2:placeOfBirth',
		    placeOfDeath: 'rdaGr2:placeOfDeath',
		    description: 'rdaGr2:biographicalInformation',
		    gender: 'rdaGr2:gender',
		    edm: 'http://www.europeana.eu/schemas/edm/',
		    hasMet: 'edm:hasMet',
		    isRelatedTo: 'edm:isRelatedTo',
		    sameAs: 'http://www.w3.org/2002/07/owl#sameA',
	  	}

	  	data.merge(super)
	  end
  end

end
