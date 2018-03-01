# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class RecordSerializer < ActiveModel::Serializer
      attributes :id, :fragments
    end
  end
end
