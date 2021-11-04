# frozen_string_literal: true

module SupplejackApi
  class ConceptSerializer < SupplejackApi::BaseSerializer
    has_many :source_authorities
    has_many :records, serializer: ConceptRecordSerializer

    attribute '@context' do
      if instance_options[:inline_context]
        Concept.build_context(ConceptSchema.model_fields.keys)
      else
        object.context
      end
    end

    attribute '@type' do
      object.concept_type
    end

    attribute '@id' do
      object.site_id
    end

    attribute :concept_id

    attribute '@reverse' do
      { object.edm_type => object.records.map { |record| ConceptRecordSerializer.new(record) } }
    end

    ConceptSchema.model_fields.each do |name, definition|
      next if definition.search_value.blank? && definition.store == false

      if definition.search_value.present? && definition.store == false
        attribute name do
          definition.search_value.call(object)
        end
      else
        attribute name do
          if object.public_send(name).nil?
            definition.default_value
          elsif definition.date_format.present?
            format_date(object.public_send(name), definition.date_format)
          else
            object.public_send(name)
          end
        end
      end
    end
  end
end
