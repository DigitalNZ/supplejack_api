# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class ConceptSearch < Search
  
    # The records that match the criteria within each role will be removed
    # from the search results
    #
    def self.role_collection_restrictions(scope)
      restrictions = []
      if scope
        role = scope.role.try(:to_sym)
  
        if ConceptSchema.roles[role].record_restrictions
          restrictions = ConceptSchema.roles[role].record_restrictions
        end
      end
      
      restrictions
    end

    def query_fields
      query_fields_list = super
      query_fields_list += [:name, :label] if (query_fields_list && [:name, :label]).present?
    end

    def search_builder
      @search_builder ||= Sunspot.new_search(Concept) do
        facet_list.each do |facet_name|
          facet(facet_name, limit: facets_per_page, offset: facets_offset)
        end
  
        # if options[:suggest]
        #   spellcheck collate: true, only_more_popular: true
        # end
  
        options[:without].each do |name, values|
          values = values.split(",")
          values.each do |value|
            without(name, self.to_proper_value(name, value))
          end
        end
  
        adjust_solr_params do |params|
          if options[:solr_query].present?
            params[:q] ||= ""
            params['q.alt'] = options[:solr_query]
            params[:defType] = 'dismax'
          end
        end
  
        # Facet Queries
        #
        # The facet query parameter should have the following format:
        #
        #   facet_query: {images: {"creator" => "all"}, headings: {"record_type" => 1}}
        #
        # - Each key in the top level hash will be the name of each facet row returned.
        # - Each value in the top level hash is a hash similar with all the restrictions
        #
  
        if options[:facet_query].any?
          facet(:counts) do
            options[:facet_query].each_pair do |row_name, filters_hash|
              row(row_name.to_s) do
                filters_hash.each_pair do |filter, value|
                  if value == "all"
                    without(filter.to_sym, nil)
                  elsif filter.match(/-(.+)/)
                    without($1.to_sym, to_proper_value(filter, value))
                  else
                    if value.is_a?(Array)
                      with(filter.to_sym).all_of(value)
                    else
                      with(filter.to_sym, to_proper_value(filter, value))
                    end
                  end
                end
              end
            end
          end
        end
  
        if options[:sort].present?
          order_by(sort, direction)
        end
  
        ConceptSearch.role_collection_restrictions(options[:scope]).each do |field, values|
          without(field, values)
        end
  
        # Source.suppressed.each do |source|
        #   without(:source_id, source.source_id)
        # end
  
        paginate :page => page, :per_page => per_page
      end
  
      @search_builder.build(&build_conditions)
      @search_builder
    end
  
	end
end