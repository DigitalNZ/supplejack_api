# frozen_string_literal: true



module SupplejackApi
  class SourceAuthoritySerializer < ActiveModel::Serializer
    attribute '@type' do
      object.concept_type
    end

    ConceptSchema.fields.each_key do |name|
      attribute name do
        object.public_send(name)
      end
    end
  end
end
