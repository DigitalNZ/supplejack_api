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

        field :internal_identifier,         type: String
        field :status,                      type: String
        field :source_url,                  type: String

        validates :internal_identifier,     presence: true
      end
    end
  end
end
