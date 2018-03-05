# frozen_string_literal: true

module SupplejackApi
  class PreviewRecordSerializer < ActiveModel::Serializer
    def attributes(*_)
      object.attributes.symbolize_keys
    end
  end
end
