# frozen_string_literal: true

module Query
  class MoreLikeThis < Base
    attr_reader :role, :record

    def initialize(record, params, role)
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
      search = Sunspot.new_more_like_this(record)
      search = QueryBuilder::Paginate.new(search, options.page, options.per_page).call
      search = QueryBuilder::Fields.new(search, options.mlt_fields).call
      search = QueryBuilder::MinimumTermFrequency.new(search, options.frequency).call
      search = QueryBuilder::Without.new(search, role_collection_restrictions(role)).call

      surpressed_source_ids = SupplejackApi::Source.suppressed.all.pluck(:source_id)
      QueryBuilder::Without.new(search, source_id: surpressed_source_ids).call
    end
  end
end
