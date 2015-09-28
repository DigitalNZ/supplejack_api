module SupplejackApi
  module FacetsHelper

    # Given a facet key, returns list of facets under that key
    #
    # @parameter facet_key [String] facet to retrieve all values of
    # @returns [Array<String>] all values for this facet
    def get_list_of_facet_values(facet_key)
      facets_list = []
      facets_page = 1

      loop do
        s = RecordSearch.new({facets: facet_key, facets_per_page: 150, facets_page: facets_page})
        # HACK: We override SearchSerializable#facets_list in the api_app to 
        # replace :display_collection with :primary_collection, this transparently fixes it
        mappings = {primary_collection: :display_collection}
        facets = Hash[s.facets_hash.map{|k, v| [mappings[k] || k, v]}][facet_key.to_sym]

        # Gone past last page of facets
        break if facets.length == 0

        facets_list << facets.keys
        facets_page += 1
      end

      facets_list.flatten
    end
    module_function :get_list_of_facet_values

  end
end
