# frozen_string_literal: true



module SupplejackApi
  class ConceptRecordSerializer < ActiveModel::Serializer
    attribute '@id' do
      "http://#{ENV['WWW_DOMAIN']}/records/#{object.record_id}"
    end

    attribute '@type' do
      'edm:ProvidedCHO'
    end

    attributes :title, :description, :date, :display_content_partner, :display_collection, :thumbnail_url
  end
end
