# frozen_string_literal: true
module SupplejackApi::Concerns::UserSet
  extend ActiveSupport::Concern

  included do
    store_in collection: 'user_sets', session: 'strong'

    belongs_to :user, class_name: 'SupplejackApi::User'
    belongs_to :record, class_name: 'SupplejackApi::Record', inverse_of: nil

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

    field :name,              type: String
    field :description,       type: String,   default: ''
    field :privacy,           type: String,   default: 'public'
    field :url,               type: String
    field :priority,          type: Integer,  default: 0
    field :count,             type: Integer,  default: 0
    field :count_updated_at,  type: DateTime
    field :tags,              type: Array,    default: []
    field :approved,          type: Boolean,  default: false
    field :featured,          type: Boolean,  default: false
    field :featured_at,       type: DateTime

    scope :excluding_favorites, -> { where(:name.ne => 'Favorites') }
    scope :publicly_viewable,              -> { where(privacy: 'public') }

    index 'set_items.record_id' => 1
    index featured: 1

    attr_accessible :name, :description, :privacy, :priority, :tags, :tag_list, :records, :approved

    validates :name, presence: true
    validates :privacy, inclusion: { in: %w(public hidden private) }

    before_validation :set_default_privacy
    before_save :calculate_count
    before_save :strip_html_tags
    before_save :update_record
    after_save :reindex_items
    before_destroy :delete_record

    # Force-capitalize only the first word of the set name
    #
    def name=(name)
      self[:name] = Utils.capitalize_first_word(name)
    end

    # Find a set based on the MongoDB ObjectID or the set url.
    #
    def self.custom_find(id)
      user_set = if id.to_s.length == 24
                   find(id) rescue nil
                 else
                   where(url: id).first
                 end
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

      if set_items = new_attributes.delete(:records)
        Rails.logger.info "DEBUGG: set_items = #{set_items}"
        if set_items.is_a? Array
          begin
            new_set_items = []
            set_items.each do |set_item_hash|
              set_item = self.set_items.find_or_initialize_by(record_id: set_item_hash['record_id'])
              set_item.position = set_item_hash['position']

              new_set_items << set_item # if valid_for_position_update(set_item)
            end

            self.set_items = new_set_items unless new_set_items.map(&:valid?).include? false
          rescue StandardError => e
            raise WrongRecordsFormat
          end
        end
      end

      if new_attributes.key?(:featured)
        featured_value = new_attributes.delete(:featured)
        if user.try(:can_change_featured_sets?)
          self.featured = featured_value
          self.featured_at = Time.now if featured_changed?
        end
      end

      self.attributes = new_attributes
      save
    end

    # Temporary solution. Ignoring position exception becuse
    # at the end of the iteration all items will have unique position
    #
    # @author Eddie
    # @last_modified Eddie
    # @param item [SetItem] the set item
    # @return [Boolean] the validity
    def valid_for_position_update(item)
      return true if item.valid?
      item.errors.messages == { position: ['is already taken'] }
    end

    def calculate_count
      self.count = records.size
    end

    def set_default_privacy
      self.privacy = 'public' if self[:privacy].blank?
    end

    def record_status
      privacy == 'public' && approved ? 'active' : 'suppressed'
    end

    # Remove HTML tags from the name, description and tags
    #
    def strip_html_tags
      [:name, :description].each do |attr|
        send("#{attr}=", strip_tags(self[attr])) if self[attr].present?
      end

      self.tags = self[:tags].map { |t| strip_tags(t) } if tags.try(:any?)
    end

    def update_record
      if set_items.empty?
        suppress_record
        return nil
      end

      self.record = SupplejackApi::Record.new if record.nil?

      record.status = record_status
      record.internal_identifier = "user_set_#{id}"

      primary_fragment = record.primary_fragment

      record.save!
    end

    def delete_record
      if record
        record.status = 'deleted'
        record.save!
      end
    end

    def suppress_record
      if record
        record.status = 'suppressed'
        record.save!
      end
    end

    def record_ids
      set_items.asc(:position).map(&:record_id)
    end

    # Return a array of actual Record objects
    #
    def records(amount = nil)
      @records ||= begin
        ids_to_fetch = record_ids || []
        records = SupplejackApi::Record.find_multiple(ids_to_fetch)
        records = records[0..amount.to_i - 1] if amount
        records
      end
    end

    def tags=(list)
      self[:tags] = *list
    end

    def tag_list=(tags_string)
      tags_string = tags_string.to_s.gsub(/[^A-Za-z0-9\p{Word} ,_-]/, '')
      self.tags = tags_string.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    def tag_list
      tags.join(', ') if tags.present?
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
        SupplejackApi::Record.custom_find(i.record_id).index rescue nil
      end
    end

    class WrongRecordsFormat < RuntimeError; end
  end
end
