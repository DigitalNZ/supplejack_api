# frozen_string_literal: true

module SupplejackApi
  class ConceptSearch < Search
    def initialize(options = {})
      super(options.merge(fields: ConceptSchema.model_fields.keys.join(',')))
    end

    def search_builder
      return @search_builder if @search_builder.present?

      @search_builder = Sunspot.new_search(SupplejackApi::Concept)
      @search_builder = QueryBuilder::Spellcheck.new(@search_builder, options.suggest).call
      @search_builder = QueryBuilder::Without.new(@search_builder, options.without).call
      @search_builder = QueryBuilder::WithBoudingBox.new(@search_builder, options.geo_bbox).call
      @search_builder = QueryBuilder::Ordering.new(
        @search_builder, SupplejackApi::Concept, options.sort, options.direction
      ).call
      @search_builder = QueryBuilder::Paginate.new(@search_builder, options.page, options.per_page).call

      @search_builder.build(&build_conditions)
      @search_builder
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
