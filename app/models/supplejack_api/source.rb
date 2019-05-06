# frozen_string_literal: true

module SupplejackApi
  class Source
    include Mongoid::Document

    SOLR_SORT_QUERY_BASE = 'syndication_date_d'
    SOLR_QUERY_LIMIT = 100

    store_in collection: 'sources', client: 'strong'

    field :source_id,            type: String
    field :status,               type: String, default: 'active'
    field :status_updated_by,    type: String
    field :status_updated_at,    type: DateTime

    belongs_to :partner, class_name: 'SupplejackApi::Partner'

    scope :suppressed,  -> { where(status: 'suppressed') }

    # Its not completely random. Its not effiient to run .sample on large collections.
    # Fetches 4 random records from first 100 and last 100
    def random_records(limit)
      first_hundred = query_solr('desc').results
      last_hundred = query_solr('asc').results

      (first_hundred | last_hundred).sample(limit)
    end

    private

    def build_query
      "source_id_s: \"#{source_id}\""
    end

    def query_solr(direction)
      sort = SOLR_SORT_QUERY_BASE.dup << " #{direction}"

      Sunspot.new_search(SupplejackApi.config.record_class) do
        adjust_solr_params do |params|
          params[:q] = build_query
          params[:sort] = sort
          params[:limit] = SOLR_QUERY_LIMIT
        end
      end.execute
    end
  end
end
