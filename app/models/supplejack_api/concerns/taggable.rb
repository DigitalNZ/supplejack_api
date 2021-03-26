# frozen_string_literal: true

# Fields, validations, scopes and callbacks relating to the tags
module SupplejackApi
  module Concerns
    module Taggable
      extend ActiveSupport::Concern

      included do
        field :tags, type: Array, default: []

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
      end
    end
  end
end
