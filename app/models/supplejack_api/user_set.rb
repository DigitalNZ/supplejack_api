# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
module SupplejackApi
  class UserSet
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActionView::Helpers::SanitizeHelper

    store_in collection: 'user_sets', client: 'strong'

    belongs_to :user, class_name: 'SupplejackApi::User'
    belongs_to :record, class_name: SupplejackApi.config.record_class.to_s, inverse_of: nil, touch: true, optional: true

    field :name,                type: String
    field :description,         type: String,   default: ''
    field :privacy,             type: String,   default: 'public'
    field :copyright,           type: Integer,  default: 0
    field :url,                 type: String
    field :priority,            type: Integer,  default: 0
    field :count_updated_at,    type: DateTime
    field :tags,                type: Array,    default: []
    field :subjects,            type: Array,    default: []
    field :approved,            type: Boolean,  default: false
    field :featured,            type: Boolean,  default: false
    field :featured_at,         type: DateTime
    field :cover_thumbnail,     type: String

    # This field was created for sorting items to know that
    # the cover_thumbnail was selected by the user so dont change it.
    # We have decided not to od this for now

    # field :user_selected_cover, type: Boolean,  default: false

    scope :excluding_favorites, -> { where(:name.ne => 'Favorites') }
    scope :publicly_viewable,   -> { where(privacy: 'public') }

    index({ 'set_items.record_id' => 1 }, background: true)
    index({ featured: 1 }, background: true)

    validates :name, presence: true
    validates :privacy, inclusion: { in: %w[public hidden private] }

    before_validation :set_default_privacy
    before_save :strip_html_tags!
    before_save :update_record
    before_destroy :delete_record
    after_save :reindex_items
    after_save :reindex_if_changed
    after_create :create_record_representation

    # we originally had this method named `#create_method`
    # however we had to change it to `#create_record_representation`
    # as `#create_record` conflicts with a Mongoid method
    # that dynamically assigns `#create_` methods with a trailing name
    #
    # In Mongoid lib/mongoid/relations/builders.rb
    def create_record_representation
      return unless record.nil?

      self.record = SupplejackApi.config.record_class.new

      record.status = record_status
      record.internal_identifier = "digitalnz_user_set_#{id}"

      primary_fragment = record.primary_fragment
      primary_fragment.thumbnail_url = cover_thumbnail

      record.save!
    end

    def reindex_if_changed
      return if record_status != 'active'

      return unless [name_changed?, description_changed?, subjects_changed?,
                     approved_changed?, privacy_changed?].any?

      primary_fragment = record.primary_fragment
      primary_fragment.title = name
      primary_fragment.description = description
      primary_fragment.subject = subjects

      record.save!
    end

    # Force-capitalize only the first word of the set name
    #
    def name=(name)
      self[:name] = Utils.capitalize_first_word(name)
    end

    # Find a set based on the MongoDB ObjectID or the set url.
    #
    def self.custom_find(id)
      mongo_object_id_char_length = 24

      if id.to_s.length == mongo_object_id_char_length
        find(id) rescue nil
      else
        where(url: id).first
      end
    end

    def self.all_public_sets
      where(privacy: 'public', :name.ne => 'Favourites').order(updated_at: :desc)
    end

    def self.public_search(options = {})
      options.reverse_merge!(page: 1, per_page: 10, order_by: :updated_at,
                             direction: :asc, search: nil)
      where(
        :name.ne => 'Favourites',
        '$or' => [
          { name: /#{options[:search]}/i },
          { user_id: options[:search] },
          { id: options[:search] }
        ]
      ).in(privacy: %w[public hidden])
        .order(options[:order_by] => options[:direction])
        .page(options[:page])
        .per(options[:per_page])
    end

    def self.public_sets(options = {})
      options.reverse_merge!(page: 1, per_page: 100)
      page = options[:page].to_i
      page = page.zero? ? 1 : page
      where(privacy: 'public', :name.ne => 'Favourites').desc(:created_at).page(page)
    end

    def self.public_sets_count
      where(privacy: 'public', :name.ne => 'Favourites').count
    end

    def self.featured_sets(num = 16)
      sets = where(privacy: 'public', featured: true).desc(:featured_at).limit(num).to_a
      sets.delete_if { |s| s.records(1).try(:empty?) }
      sets
    end

    # Accept a hash of attributes with the user_set attributes, a array
    # of hashes with the set_items information and a optional "featured"
    # attribute which only the administrator is allowed to modify
    #
    def update_attributes_and_embedded(new_attributes = {}, user = nil)
      new_attributes = new_attributes.try(:symbolize_keys) || {}

      new_attributes[:description] = '' unless new_attributes[:description]
      new_attributes[:approved] = false unless new_attributes[:approved]

      update_set_items(new_attributes)
      update_featured_set(new_attributes, user)

      self.attributes = new_attributes
      save
    end

    def update_featured_set(new_attributes, user)
      return unless new_attributes.key?(:featured)

      featured_value = new_attributes.delete(:featured)

      return unless user.try(:can_change_featured_sets?)

      self.featured = featured_value

      self.featured_at = Time.now.utc if featured_changed?
    end

    def update_set_items(new_attributes)
      set_items = new_attributes.delete(:records)

      return unless set_items
      return unless set_items.is_a? Array

      begin
        new_set_items = []
        set_items.each do |set_item_hash|
          set_item_hash.symbolize_keys!
          # This ugly fix should be removed when digitalnz.org is decommissioned
          params = set_item_hash.merge(record_id: set_item_hash[:record_id], type: 'embed',
                                       sub_type: 'record', content: { record_id: set_item_hash[:record_id] },
                                       meta: { align_mode: 0 })

          # set_item = self.set_items.find_or_initialize_by(params)

          unless (set_item = self.set_items.find_by_record_id(params[:record_id]))
            set_item = self.set_items.new(params)
          end

          set_item.position = set_item_hash[:position]

          new_set_items << set_item
        end

        self.set_items = new_set_items.map { |item| item if item.valid? }.compact
      rescue StandardError
        raise WrongRecordsFormat
      end
    end

    def count
      records.size
    end

    def set_default_privacy
      self.privacy = 'public' if self[:privacy].blank?
    end

    def record_status
      privacy == 'public' && approved ? 'active' : 'suppressed'
    end

    # Remove HTML tags from the name, description and tags
    #
    def strip_html_tags!
      %i[name description].each do |attr|
        send("#{attr}=", strip_tags(self[attr])) if self[attr].present?
      end

      self[:subjects] = [] unless self[:subjects]
      self.subjects = self[:subjects].map { |subject| strip_tags(subject) }

      self[:tags] = [] unless self[:tags]
      self.tags = self[:tags].map { |tag| strip_tags(tag) }
    end

    def update_record
      suppress_record if set_items.empty?

      self.record = SupplejackApi.config.record_class.new if record.nil?

      record.status = record_status
      record.internal_identifier = "user_set_#{id}"

      primary_fragment = record.primary_fragment
      primary_fragment.thumbnail_url = cover_thumbnail

      record.save!
    end

    def delete_record
      return unless record

      record.status = 'deleted'
      record.save!
    end

    def suppress_record
      return unless record

      record.status = 'suppressed'
      record.save!
    end

    def record_ids
      set_items.asc(:position).map(&:record_id)
    end

    # Return a array of actual Record objects
    #
    def records(amount = nil)
      @records ||= begin
        ids_to_fetch = record_ids || []
        records = SupplejackApi.config.record_class.find_multiple(ids_to_fetch)
        records = records[0..amount.to_i - 1] if amount
        records
      end
    end

    def tags=(list)
      self[:tags] = *list
    end

    def tag_list=(tags_string)
      tags_string = tags_string.to_s.gsub(/[^\w ,-]/, '')
      self.subjects = tags_string.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    def tag_list
      subjects.join(', ') if subjects.present?
    end

    # Return a array of SetItem objects with the actual Record object attached through
    # the "record" virtual attribute.
    #
    # The set items are sorted by position.
    #
    def items_with_records(amount = nil)
      records = self.records(amount)

      items_with_records = set_items.map do |set_item|
        set_item.record = records.detect { |r| r.record_id == set_item.record_id }
        set_item
      end

      items_with_records.reject { |i| i.record.nil? }.sort_by(&:position)
    end

    def reindex_items
      set_items.each do |i|
        SupplejackApi.config.record_class.custom_find(i.record_id).index rescue nil
      end
    end

    class WrongRecordsFormat < RuntimeError; end

    # Finds and returns a UserSet with id
    #
    # @author Eddie
    # @last_modified Eddie
    # @return [Object] the set_item
    def self.find_by_id(id)
      where(id: id).first
    end

    embeds_many :set_items, class_name: 'SupplejackApi::SetItem' do
      def find_by_record_id(record_id)
        where(record_id: record_id).first
      end

      # Finds a set item and returns it
      #
      # @author Eddie
      # @last_modified Eddie
      # @param id [String] the id
      # @return [SetItem] the item
      def find_by_id(id)
        where(id: id).first
      end
    end
  end
end
# rubocop:enable Metrics/ClassLength
