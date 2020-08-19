# frozen_string_literal: true

module SupplejackApi
  class MltSerializer < ActiveModel::Serializer
    attribute :id

    RecordSchema.fields.each do |name, definition|
      if definition.search_value.present? && definition.store == false
        attribute name do
          definition.search_value.call(object)
        end
      else
        attribute name do
          object.public_send(name).nil? ? definition.default_value : object.public_send(name)
        end
      end
    end
  end
end
