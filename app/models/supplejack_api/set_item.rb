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

    validates :record_id, allow_blank: true, uniqueness: true, numericality: { greater_than: 0 }

    validates :position, presence: true, uniqueness: true
    validates :type,     presence: { message: 'Mandatory Parameters Missing: type is missing' }
    validates :sub_type, presence: { message: 'Mandatory Parameters Missing: sub_type is missing' }

    validate :valid_type_sub_type,       if: -> { type && sub_type }
    validate :valid_type_text_heading,   if: -> { type == 'text' && sub_type == 'heading' }
    validate :valid_type_text_rich_text, if: -> { type == 'text' && sub_type == 'rich-text' }
    validate :valid_type_embed_record,   if: -> { type == 'embed' && sub_type == 'record' }

    validate :not_adding_set_to_itself

    before_validation :set_position
    after_destroy :reindex_record

    def valid_type_sub_type
      if %w[text embed].include? type
        if type == 'text'
          return if %w[heading rich-text].include? sub_type

          errors.add(:type, 'Unsupported Value: sub_type must be one of: heading or rich-text')
        else
          return if  sub_type == 'record'

          errors.add(:type, 'Unsupported Value: sub_type must record')
        end
      else
        errors.add(:type, 'Unsupported Value: type must be one of: text or embed')
      end
    end

    # Make content check a seperate method
    def valid_type_embed_record
      if content
        if content[:id] && !(content[:id].is_a?(Integer) || content[:id] =~ /^\d+$/)
          errors.add(:content, 'Unsupported Value: content must contain integer field id')
        end
      else
        errors.add(:content, 'Content is missing')
      end

      if meta.blank?
        errors.add(:meta, 'Meta is missing')
      else
        return unless meta[:alignment] && %w[left center right].exclude?(meta[:alignment])

        errors.add(:meta, 'Unsupported Values: alignment must be one of: left center or right in meta')
      end
    end

    def valid_type_text_rich_text
      errors.add(:content, 'Content is missing') if content.blank?
    end

    def valid_type_text_heading
      errors.add(:content, 'Content is missing') if content.blank?

      errors.add(:meta, 'Meta is missing') if meta.blank?

      return unless meta[:size] && [1, 2, 3, 4, 5, 6].exclude?(meta[:size])

      errors.add(:meta, 'Unsupported Values: size must be one of: 1, 2, 3, 4, 5, 6 in meta')
    end

    # The Schema validations for meta and content require the keys to be symbols
    def meta
      self[:meta].deep_symbolize_keys if self[:meta]
    end

    def content
      return unless self[:content]

      if self[:content][:value]
        self[:content][:value] = Rails::Html::SafeListSanitizer.new.sanitize(
          self[:content][:value],
          tags: %w[p strong em u ul li ol a h1 h2 h3]
        )
      end

      self[:content].deep_symbolize_keys
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
