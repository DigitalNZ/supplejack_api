# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module ApiRecord
    module Storable
      extend ActiveSupport::Concern
  
      included do 
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'records'
  
        index({record_id: 1}, {unique: true})
        index status: 1
        index internal_identifier: 1
        index landing_url: 1
        index updated_at: 1
        
        auto_increment :record_id, session: 'strong', collection: 'records'
  
        field :internal_identifier,         type: String
        field :landing_url,                 type: String
        field :status,                      type: String

        validates :internal_identifier,     presence: true
        validates :landing_url,             url: true
      end 
    end
  end
end