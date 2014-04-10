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
        
        auto_increment :record_id, session: "strong"
  
        field :internal_identifier,         type: String
        field :landing_url,                 type: String
        field :status,                      type: String

        validates :internal_identifier,     presence: true
        validates :landing_url,             url: true
      end 
    end
  end
end