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
      integer_ids = ids.find_all { |id| id.to_s.length <= 10 }

      records = []
      records += active.find(string_ids) if string_ids.present?
      records += active.where(:record_id.in => integer_ids)

      records.sort_by do |record|
        ids.find_index(record.record_id) || ids.find_index(record.record_id.to_s) || 100
      end
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
      total_pages = (search.total.to_f / search.options.per_page).ceil

      self.next_page = search.options.page
      self.previous_page = search.options.page

      return unless record_index

      if record_index.zero?
        if search.options.page != 1
          previous_page_search = ::SupplejackApi::RecordSearch.new(options.merge(page: search.options.page - 1))
          previous_primary_key = previous_page_search.hits[-1]&.primary_key
          self.previous_page = search.options.page - 1
        end
      else
        previous_primary_key = search.hits[record_index - 1]&.primary_key
      end

      if previous_primary_key.present?
        self.previous_record = SupplejackApi::Record.find(previous_primary_key)&.record_id rescue nil
      end

      if record_index == search.hits.size - 1
        if search.options.page < total_pages
          next_page_search = ::SupplejackApi::RecordSearch.new(options.merge(page: search.options.page + 1))
          next_primary_key = next_page_search.hits[0]&.primary_key
          self.next_page = search.options.page + 1
        end
      else
        next_primary_key = search.hits[record_index + 1]&.primary_key
      end

      return if next_primary_key.blank?

      self.next_record = SupplejackApi::Record.find(next_primary_key)&.record_id rescue nil
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
  end
end
