# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module SearchSerializer
      extend ActiveSupport::Concern

      included do
        attribute :page do
          object.options.page
        end

        attribute :per_page do
          object.options.per_page
        end

        attribute :result_count do
          if object.options.group_by.present?
            object.group(object.options.group_by).total
          else
            object.total
          end
        end

        attribute :request_url do
          # I tried to call this option request_url
          # but it doesn't get passed into instance_options
          # I have no idea why
          instance_options[:record_url]
        end

        attribute :solr_request_params, if: -> { object.solr_request_params }

        attribute :results do
          options = {
            fields: instance_options[:record_fields],
            include: instance_options[:record_includes],
            root: 'results'
          }

          if object.options.group_by.present?
            ActiveModelSerializers::SerializableResource.new(
              object.group(object.options.group_by).groups.flat_map(&:results), options
            )
          else
            ActiveModelSerializers::SerializableResource.new(object.results, options)
          end
        end
      end
    end
  end
end
