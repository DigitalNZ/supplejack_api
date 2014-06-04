# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Search
    include ActiveModel::SerializerSupport
  
    INTEGER_ATTRIBUTES ||= [:page, :per_page, :facets_per_page, :facets_page, :record_type]
    attr_accessor :options, :request_url, :scope, :solr_request_params, :errors, :warnings
  
    class_attribute :max_values
    
    self.max_values = {
      page: 100000, 
      per_page: 100, 
      facets_per_page: 150, 
      facets_page: 5000
    }
  
    def initialize(options={})
      @options = options.dup
      @options.reverse_merge!(
        facets: '', 
        and: {}, 
        or: {}, 
        without: {}, 
        page: 1, 
        per_page: 20, 
        record_type: 0, 
        facets_per_page: 10, 
        facets_page: 1, 
        sort: nil, 
        direction: 'desc', 
        fields: 'default', 
        facet_query: {}, 
        debug: nil
      )
    end
  
  end
end
