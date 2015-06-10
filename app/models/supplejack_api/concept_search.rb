# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
	class ConceptSearch < Search

    def initialize(options={})
      @options = options.dup
      @options.reverse_merge!(
        facets: '', 
        and: {}, 
        or: {}, 
        without: {}, 
        page: 1, 
        per_page: 20, 
        record_type: 0, 
        facets_per_page: 10, 
        facets_page: 1, 
        sort: nil, 
        direction: 'desc', 
        fields: ConceptSchema.model_fields.keys.join(','), 
        facet_query: {}, 
        debug: nil
      )
    end

    def query_fields
      query_fields_list = super
      query_fields_list += [:name, :label] if (query_fields_list && [:name, :label]).present?
    end

    def field_list
      return @field_list if @field_list
      model_fields = ConceptSchema.model_fields.dup
      valid_fields = model_fields.keep_if { |key, field| field.try(:store) == nil }

      @field_list = options[:fields].split(",").map {|f| f.strip.gsub(':', '_').to_sym}
      @field_list.delete_if do |f|
        !valid_fields.include?(f)
      end
      
      @field_list
    end

    def group_list
      return @group_list if @group_list
      @group_list = options[:fields].split(',').map {|f| f.strip.to_sym}
      @group_list.keep_if {|f| ConceptSchema.groups.keys.include?(f) }
      @group_list
    end
  
	end
end