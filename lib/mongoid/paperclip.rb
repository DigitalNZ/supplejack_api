# frozen_string_literal: true

#
# Save this into your `lib/mongoid/paperclip.rb` file
#
#
require 'paperclip'

module Paperclip
  class << self
    def logger
      Rails.logger
    end
  end
end

##
# the id of mongoid is not integer, correct the id_partitioin.
Paperclip.interpolates :id_partition do |attachment, _style|
  attachment.instance.id.to_s.scan(/.{4}/).join('/')
end

module Mongoid
  module Paperclip
    def self.included(base)
      base.instance_eval do
        include ::Paperclip
        include ::Paperclip::Glue

        alias :__mongoid_has_attached_file :has_attached_file

        extend ClassMethods
      end
    end

    module ClassMethods
      def has_attached_file(field, options = {})
        field(:"#{field}_file_name",    type: String)
        field(:"#{field}_content_type", type: String)
        field(:"#{field}_file_size",    type: Integer)
        field(:"#{field}_updated_at",   type: DateTime)

        __mongoid_has_attached_file(field, options)
      end
    end
  end
end
