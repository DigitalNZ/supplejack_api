# frozen_string_literal: true

module SupplejackApi
  class SetItem
    include Mongoid::Document

    ATTRIBUTES = RecordSchema.groups[:valid_set_fields].fields

    attr_accessor :record

    #  touch: true ensures that the parent user_set updates its updated_at field when the set_item is edited and saved.
    embedded_in :user_set, class_name: 'SupplejackApi::UserSet', touch: true

    field :record_id,   type: Integer
    field :position,    type: Integer

    field :type,        type: String
    field :sub_type,    type: String
    field :content,     type: Hash,  default: {}
    field :meta,        type: Hash,  default: {}

    # validates :record_id,   presence: true, uniqueness: true, numericality: { greater_than: 0 }
    validates :record_id,   allow_blank: true, uniqueness: true, numericality: { greater_than: 0 }
    validates :position,    presence: true, uniqueness: true
    validate  :not_adding_set_to_itself

    before_validation :set_position
    after_destroy :reindex_record

    # The Schema validations for meta and content require the keys to be symbols
    def meta
      self[:meta].deep_symbolize_keys if self[:meta]
    end

    def content
      self[:content].deep_symbolize_keys if self[:content]
    end

    def not_adding_set_to_itself
      return unless user_set.record && record_id == user_set.record.record_id

      errors.add(:set, "can't be added to itself")
    end

    # Dynamically define methods for the attributes that get added to the set_item from
    # the actual Record.
    #
    ATTRIBUTES.each do |record_attr|
      define_method(record_attr) do
        record.try(:send, record_attr)
      end
    end

    # Set the default position as the last in the set, if not defined.
    #
    def set_position
      return if position && position != -1

      positions = user_set.set_items.map(&:position)
      self.position = positions.compact.max.to_i + 1
    end

    def reindex_record
      SupplejackApi.config.record_class.custom_find(record_id).index rescue nil
    end
  end
end
