# frozen_string_literal: true

module SupplejackApi
  class MoreLikeThisSearch < BaseSearch
    attr_reader :role, :record

    def initialize(record, role, params)
      super(SupplejackApi::MltParams.new(
        **params.merge(
          schema_class: RecordSchema, model_class: SupplejackApi::Record
        )
      ))
      @record = record
      @role = role
    end

    private

    def query
      suppressed_source_ids = SupplejackApi::Source.suppressed.all.pluck(:source_id)

      search = Sunspot.new_more_like_this(record)
      search = QueryBuilder::RecordType.new(search, options.record_type).call
      search = QueryBuilder::WithBoudingBox.new(search, options.geo_bbox).call
      search = QueryBuilder::Paginate.new(search, options.page, options.per_page).call
      search = QueryBuilder::Fields.new(search, options.mlt_fields).call
      search = QueryBuilder::MinimumTermFrequency.new(search, options.frequency).call
      search = QueryBuilder::Ordering.new(search, options).call
      search = QueryBuilder::Defaults.new(search).call
      search = QueryBuilder::Without.new(search, source_id: suppressed_source_ids).call
      search = QueryBuilder::Without.new(search, role_collection_restrictions(role)).call
      search = QueryBuilder::Without.new(search, options.without).call
      QueryBuilder::AndOrFilters.new(search, options).call
    end
  end
end
