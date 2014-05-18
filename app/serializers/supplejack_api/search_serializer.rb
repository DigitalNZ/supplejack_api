# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SearchSerializer < ApplicationSerializer
    
    def serializable_hash    
      hash = {}
      hash[:result_count] = object.total
      hash[:results] = records_serialized_array
      hash[:per_page] = object.per_page
      hash[:page] = object.page
      hash[:request_url] = object.request_url
      hash[:solr_request_params] = object.solr_request_params if object.solr_request_params
      hash[:warnings] = object.warnings if object.warnings.present?
      hash[:suggestion] = object.collation if object.options[:suggest]
      hash
    end
    
    # Returns a hash of facets in the following format:
    # 
    #    "content_partner": {
    #      "Matapihi": 182101,
    #      "Alexander Turnbull Library": 67766,
    #    },
    #    "category": {
    #      "Images": 186111,
    #    }
    #
    def json_facets
      facets = {}
      object.facets.map do |facet|
        rows = {}
        facet.rows.each do |row|
          rows[row.value] = row.count
        end
          
        facets.merge!({facet_name(facet.name) => rows})
      end
      facets
    end
    
    # Returns an array of facets in the following format:
    #
    #   [
    #     { 
    #       name: "content_partner", 
    #       values: [{name: "Matapihi", count: 182101}, {name: "Alexander Turnbull Library", count: 67766}]
    #     },
    #     { 
    #       name: "category", 
    #       values: [{name: "Images", count: 186111}]
    #     }
    #   ]
    #
    def xml_facets
      facets = []
      object.facets.map do |facet|
        values = facet.rows.map do |row|
          { name: row.value, count: row.count }
        end
        facets << {name: facet_name(facet.name).to_s, values: values}
      end
      facets
    end
    
    def to_json(options={})
      rendered_json = as_json(options).to_json
      rendered_json = "#{object.jsonp}(#{rendered_json})" if object.jsonp
      rendered_json
    end
    
    def as_json(options={})
      hash = { search: serializable_hash }
      hash[:search][:facets] = json_facets
      hash
    end
    
    def to_xml(*args)
      hash = serializable_hash
      hash[:facets] = xml_facets
      
      options = {}
      options = args.first.merge(:root => :search) if args.first.is_a?(Hash)
      
      hash.to_xml(options)
    end
    
    def records_serialized_array
      ActiveModel::ArraySerializer.new(object.results, {fields: object.field_list, groups: object.group_list, scope: object.scope})
    end
  
    private
  
    # **category**: *dnz*
    def facet_name(name)
      if name.to_s == 'primary_collection' and object.display_collection?
        'display_collection'
      else
        name
      end
    end
  end

end
