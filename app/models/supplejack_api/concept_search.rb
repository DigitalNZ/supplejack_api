# frozen_string_literal: true

module SupplejackApi
  class ConceptSearch < Search
    def initialize(options = {})
      super(options.merge(fields: ConceptSchema.model_fields.keys.join(',')))
    end

    def search_builder
      @search_builder ||= begin
        search = Sunspot.new_search(SupplejackApi::Concept)
        search = QueryBuilder::Spellcheck.new(search, options.suggest).call
        search = QueryBuilder::Without.new(search, options.without).call
        search = QueryBuilder::WithBoudingBox.new(search, options.geo_bbox).call
        search = QueryBuilder::Ordering.new(search, options).call
        search = QueryBuilder::Paginate.new(search, options.page, options.per_page).call
        QueryBuilder::AndOrFilters.new(search, options).call
      end
    end

    def query_fields
      query_fields_list = super
      query_fields_list += %i[name label] if (query_fields_list && %i[name label]).present?
    end

    def field_list
      return @field_list if @field_list

      model_fields = ConceptSchema.model_fields.dup
      valid_fields = model_fields.keep_if { |_key, field| field.try(:store).nil? }

      @field_list = options[:fields].split(',').map { |f| f.strip.tr(':', '_').to_sym }
      @field_list.keep_if do |f|
        valid_fields.include?(f)
      end

      @field_list
    end

    def group_list
      return @group_list if @group_list

      @group_list = options[:fields].split(',').map { |f| f.strip.to_sym }
      @group_list.keep_if { |f| ConceptSchema.groups.keys.include?(f) }
      @group_list
    end
  end
end
