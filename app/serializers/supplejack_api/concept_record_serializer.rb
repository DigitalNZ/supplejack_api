# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class ConceptRecordSerializer < ActiveModel::Serializer

    attributes :title, :description, :date, :display_content_partner, :display_collection, :thumbnail_url

    TYPE_PROXY = 'edm:ProvidedCHO'

    def serializable_hash
      hash = {}
      hash['@id'] = "http://#{ENV['WWW_DOMAIN']}/records/#{object.record_id}"
      hash['@type'] = TYPE_PROXY
      hash = hash.merge!(attributes)
      hash
    end
  end
end