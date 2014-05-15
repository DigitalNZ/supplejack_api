# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Source
    include Mongoid::Document

    store_in collection: 'sources', session: 'strong'
  
    attr_accessible :name, :source_id, :_id, :partner_id, :status
  
    field :name,        type: String
    field :source_id,   type: String
    field :status, 		type: String, default: 'active'
  
    belongs_to :partner, class_name: 'SupplejackApi::Partner'
  
    validates :name, presence: true
  
    scope :suppressed,  -> { where(status: 'suppressed') }
  end
end
