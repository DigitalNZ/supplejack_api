# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserSet
    include Mongoid::Document
    include Mongoid::Timestamps
    include ActionView::Helpers::SanitizeHelper

    store_in collection: 'user_sets', session: 'strong'

    belongs_to :user, class_name: 'SupplejackApi::User'

    embeds_many :set_items, class_name: 'SupplejackApi::SetItem' do
      def find_by_record_id(record_id)
        where(record_id: record_id).first
      end
    end

    field :name,              type: String
    field :description,       type: String
    field :privacy,           type: String,   default: "public"
    field :url,               type: String
    field :priority,          type: Integer,  default: 0
    field :count,             type: Integer,  default: 0
    field :count_updated_at,  type: DateTime
    field :tags,              type: Array,    default: []
    field :approved,          type: Boolean,  default: false
    field :featured,          type: Boolean,  default: false
    field :featured_at,       type: DateTime

    index "set_items.record_id" => 1
    index featured: 1

    before_validation :set_default_privacy
    
    validates :name, presence: true
    validates :privacy, inclusion: {in: ["public", "hidden", "private"]}

    before_save :calculate_count
    before_save :strip_html_tags

    attr_accessible :name, :description, :privacy, :priority, :tags, :tag_list, :records, :approved
    
    # Force-capitalize only the first word of the set name
    #
    def name=(name)
      write_attribute(:name, Utils.capitalize_first_word(name))
    end

    # Find a set based on the MongoDB ObjectID or the set url.
    #
    def self.custom_find(id)
      if id.to_s.length == 24
        user_set = find(id) rescue nil
      else
        user_set = where(url: id).first
      end
    end

    def self.public_sets(options={})
      options.reverse_merge!(page: 1, per_page: 100)
      page = options[:page].to_i
      page = page == 0 ? 1 : page
      where(privacy: "public", :name.ne => "Favourites").desc(:created_at).page(page)
    end

    def self.public_sets_count
      where(privacy: "public", :name.ne => "Favourites").count
    end

    def self.featured_sets(num=16)
      sets = where(privacy: "public", featured: true).desc(:featured_at).limit(num).to_a
      sets.delete_if { |s| s.records(1).try(:empty?) }
      sets
    end

    # Accept a hash of attributes with the user_set attributes, a array
    # of hashes with the set_items information and a optional "featured"
    # attribute which only the administrator is allowed to modify
    #
    def update_attributes_and_embedded(new_attributes={}, user=nil)
      new_attributes = new_attributes.try(:symbolize_keys) || {}

      if set_items = new_attributes.delete(:records)
        if set_items.is_a? Array
          begin
            new_set_items = []
            set_items.each do |set_item_hash|
              set_item = self.set_items.find_or_initialize_by(record_id: set_item_hash["record_id"])
              set_item.position = set_item_hash["position"]
              new_set_items << set_item if set_item.valid?
            end
            self.set_items = new_set_items
          rescue StandardError => e
            raise WrongRecordsFormat
          end
        end
      end
      
      if new_attributes.has_key?(:featured) 
        featured_value = new_attributes.delete(:featured)
        if user.try(:can_change_featured_sets?)
          self.featured = featured_value
          self.featured_at = Time.now if self.featured_changed?
        end
      end

      self.attributes = new_attributes
      self.save
    end

    def calculate_count
      self.count = records.size
    end

    def set_default_privacy
      self.privacy = "public" if self[:privacy].blank?
    end

    def record_status
      self.privacy == "public" && approved ? "active" : "suppressed"
    end  

    # Remove HTML tags from the name, description and tags
    #
    def strip_html_tags
      [:name, :description].each do |attr|
        self.send("#{attr}=", strip_tags(self[attr])) if self[attr].present?
      end

      self.tags = self[:tags].map {|t| strip_tags(t) } if self.tags.try(:any?)
    end

    def record_ids
      set_items.asc(:position).map(&:record_id)
    end

    # Return a array of actual Record objects 
    #
    def records(amount=nil)
      @records ||= begin
        ids_to_fetch = self.record_ids || []
        records = Record.find_multiple(ids_to_fetch)
        records = records[0..amount.to_i-1] if amount
        records
      end
    end

    def tags=(list)
      self[:tags] = *list
    end

    def tag_list=(tags_string)
      tags_string = tags_string.to_s.gsub(/[^A-Za-z0-9 ,_-]/, "")
      self.tags = tags_string.to_s.split(',').map(&:strip).reject(&:blank?)
    end

    def tag_list
      self.tags.join(", ") if self.tags.present?
    end

    # Return a array of SetItem objects with the actual Record object attached through
    # the "record" virtual attribute. 
    #
    # The set items are sorted by position.
    #
    def items_with_records(amount=nil)
      records = self.records(amount)

      items_with_records = self.set_items.map do |set_item|
        set_item.record = records.detect {|r| r.record_id == set_item.record_id}
        set_item
      end

      items_with_records.reject { |i| i.record.nil? }.sort_by(&:position)
    end

    class WrongRecordsFormat < Exception; end
  end
end
