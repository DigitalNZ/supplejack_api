# frozen_string_literal: true

module SupplejackApi
  class PreviewRecordSerializer < ActiveModel::Serializer
    def attributes(*args)
      object.attributes.symbolize_keys
    end
  end
end
