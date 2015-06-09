# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Concept
    include Support::Concept::Storable
    include ActiveModel::SerializerSupport

    attr_accessor :id, :context

    has_many :source_authorities, class_name: 'SupplejackApi::SourceAuthority'

    def self.custom_find(id, scope=nil, options={})
      options ||= {}
      class_scope = self.unscoped
      column = "#{self.name.demodulize.downcase}_id"

      if id.to_s.match(/^\d+$/)
        data = class_scope.where(column => id).first
      elsif id.to_s.match(/^[0-9a-f]{24}$/i)
        data = class_scope.find(id)
      end
  
      raise Mongoid::Errors::DocumentNotFound.new(self, [id], [id]) unless data
        
      data
    end
  end
end
