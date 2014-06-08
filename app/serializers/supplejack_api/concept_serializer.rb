# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptSerializer < ActiveModel::Serializer

     def serializable_hash
      hash = attributes
      include_context_fields!(hash)

      groups = (options[:groups] & ConceptSchema.groups.keys) || []

      fields = Set.new
      groups.each do |group|
        fields.merge(ConceptSchema.groups[group].try(:fields))
      end

      fields.each do |field|
        hash[field] = field_value(field, options)
      end

      include_individual_fields!(hash)
      hash
    end

    def include_context_fields!(hash)
      hash['@context'] = {
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
      hash
    end

    def include_individual_fields!(hash)
      if self.options[:fields].present?
        self.options[:fields].each do |field|
          hash[field] = concept.send(field)
        end
      end
      hash
    end

    def field_value(field, options={})
      value = nil
      if ConceptSchema.fields[field].try(:search_value) && ConceptSchema.fields[field].try(:store) == false
        value = ConceptSchema.fields[field].search_value.call(object)
      else
        value = object.public_send(field)
      end
  
      value
    end

  end

end
