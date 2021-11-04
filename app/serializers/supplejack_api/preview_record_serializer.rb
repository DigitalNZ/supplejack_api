# frozen_string_literal: true

module SupplejackApi
  class PreviewRecordSerializer < SupplejackApi::BaseSerializer
    def attributes(*_)
      object.attributes.merge(id: object._id.to_s).symbolize_keys
    end
  end
end
