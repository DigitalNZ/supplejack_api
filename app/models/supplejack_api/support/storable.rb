# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Support
    module Storable
      extend ActiveSupport::Concern

    	included do
        include Mongoid::Document
    		include Mongoid::Timestamps

        # index status: 1
        # index internal_identifier: 1
        # index landing_url: 1
        # index updated_at: 1

        field :internal_identifier,         type: String
        field :landing_url,                 type: String
        field :status,                      type: String

        validates :internal_identifier,     presence: true
        validates :landing_url,             url: true

        def landing_url=(url)
          url = Array(url).first
          self["landing_url"] = url.gsub(/replace_this/, self.send(:"#{self.class.name.demodulize.downcase}_id").to_s) if url.present?
        end
      end  
    end
  end
end
