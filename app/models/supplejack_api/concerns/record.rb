# frozen_string_literal: true

module SupplejackApi::Concerns::Record
  extend ActiveSupport::Concern

  included do
    attr_accessor :next_record, :previous_record, :next_page, :previous_page
    attr_accessor :should_index_flag

    # Associations
    embeds_many :fragments, cascade_callbacks: true, class_name: 'SupplejackApi::ApiRecord::RecordFragment'
    embeds_one :merged_fragment, cascade_callbacks: true, class_name: 'SupplejackApi::ApiRecord::RecordFragment'
    has_and_belongs_to_many :concepts, class_name: 'SupplejackApi::Concept'

    # From storable
    store_in collection: 'records'
    index({ concept_ids: 1 }, background: true)
    index({ record_id: 1 }, unique: true, background: true)

    auto_increment :record_id, client: 'strong'

    # Callbacks
    before_save :merge_fragments
    before_save :mark_for_indexing
    after_save :replace_stories_cover

    # Scopes
    scope :active,          -> { where(status: 'active') }
    scope :deleted,         -> { where(status: 'deleted') }
    scope :suppressed,      -> { where(status: 'suppressed') }
    scope :solr_rejected,   -> { where(status: 'solr_rejected') }

    scope :ready_for_indexing, -> { where(index_updated: false) }

    build_model_fields

    def self.created_on(date)
      where(:created_at.gte => date.at_beginning_of_day, :created_at.lte => date.at_end_of_day)
    end

    def self.find_multiple(ids)
      return [] unless ids.try(:any?)

      string_ids = ids.find_all { |id| id.to_s.length > 10 }
      integer_ids = ids.find_all { |id| id.to_s.length <= 10 }.map(&:to_i)

      records = []
      records += active.find(string_ids) if string_ids.present?
      records += active.where(:record_id.in => integer_ids)

      records.sort_by { |r| integer_ids.find_index(r.record_id) || 100 }
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    # FIXME: make me smaller!
    def find_next_and_previous_records(scope, options = {})
      return unless options.try(:any?)

      search = ::SupplejackApi::RecordSearch.new(options)
      search.scope = scope

      return nil unless search.valid? && !search.hits.nil?

      # Find the index in the array for the current record
      record_index = search.hits.find_index { |i| i.primary_key == id.to_s }
      total_pages = (search.total.to_f / search.per_page).ceil

      self.next_page = search.page
      self.previous_page = search.page

      return unless record_index

      if record_index.zero?
        unless search.page == 1
          previous_page_search = ::SupplejackApi::RecordSearch.new(options.merge(page: search.page - 1))
          previous_primary_key = previous_page_search.hits[-1].try(:primary_key)
          self.previous_page = search.page - 1
        end
      else
        previous_primary_key = search.hits[record_index - 1].try(:primary_key)
      end

      if previous_primary_key.present?
        self.previous_record = SupplejackApi::Record.find(previous_primary_key).try(:record_id) rescue nil
      end

      if record_index == search.hits.size - 1
        unless search.page >= total_pages
          next_page_search = ::SupplejackApi::RecordSearch.new(options.merge(page: search.page + 1))
          next_primary_key = next_page_search.hits[0].try(:primary_key)
          self.next_page = search.page + 1
        end
      else
        next_primary_key = search.hits[record_index + 1].try(:primary_key)
      end

      return if next_primary_key.blank?

      self.next_record = SupplejackApi::Record.find(next_primary_key).try(:record_id) rescue nil
    end
    # rubocop:enable Metrics/MethodLength

    def active?
      status == 'active'
    end

    def should_index?
      return should_index_flag unless should_index_flag.nil?

      active?
    end

    def fragment_class
      SupplejackApi::ApiRecord::RecordFragment
    end

    def mark_for_indexing
      self.index_updated = false
      self.index_updated_at = nil
    end

    def replace_stories_cover
      return unless RecordSchema.fields.include?(:thumbnail_url) && RecordSchema.fields.include?(:large_thumbnail_url)
      return if active?

      SupplejackApi::UserSet.where(
        'set_items.record_id': record_id,
        :cover_thumbnail.in => [large_thumbnail_url, thumbnail_url].compact
      ).each do |user_set| # rubocop:disable Rails/FindEach. Mongoid::Criteria handles batching internally (not via find_each)
        active_set_item_records =
          SupplejackApi
          .config
          .record_class
          .active
          .where(:record_id.in => user_set.set_items.map(&:record_id))
        active_record_map = active_set_item_records.index_by(&:record_id)

        user_set.set_items.order([:position]).each do |set_item|
          record = active_record_map[set_item.record_id]

          next if record.nil?

          user_set.update!(cover_thumbnail: record.large_thumbnail_url)
          break # Prevent updating multiple times
        end
      end
    end
  end
end
