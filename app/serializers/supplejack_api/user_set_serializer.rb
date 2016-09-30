# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserSetSerializer < ActiveModel::Serializer
    attributes :name, :count, :priority, :featured, :approved, :created_at, :updated_at, :tags, :privacy
    has_one :record, serializer: UserSetRecordSerializer
    root :set

    def serializable_hash
      hash = { id: object.id.to_s }
      hash.merge! attributes

      options.reverse_merge!(items: true)

      include!(:record, node: hash)

      if options[:items]
        hash[:description] = object.description
        hash[:privacy] = object.privacy
        hash[:tags] = object.tags
        hash[:records] = records
      elsif options[:featured]
        hash[:records] = records(1)
      else
        hash[:records] = simple_records
      end

      hash[:user] = user if options[:user]

      hash
    end

    # Returns a array of Hashes with the information from each record
    # included in the Hash
    #
    # The values to be added from the record are stored in SetItem::ATTRIBUTES
    #
    def records(amount = nil)
      attributes = [:record_id, :position] + RecordSchema.groups[:sets].fields

      if options[:fields]
        fields = options[:fields].split(',').map(&:to_sym)
        # This is done to prevent people from passing random fields and breaking the API
        fields.reject! { |field| !SetItem::ATTRIBUTES.include? field }
        attributes.concat(fields)
      end

      object.items_with_records(amount).map do |item|
        Hash[attributes.map { |attr| [attr, item.send(attr)] }]
      end
    end

    # Returns a array of Hashes with only the record_id and position
    #
    def simple_records
      object.set_items.map do |item|
        { record_id: item.record_id, position: item.position }
      end
    end

    # Return the user information about the set, this is only displyed
    # on the set show endpoint.
    #
    # When the user requesting the sets is a admin, also return the API Key
    # for the owner of the set. This is required in order for applications
    # to make requests on the user's behalf.
    #
    def user
      hash = { name: object.user.try(:name) }

      admin = options[:user]
      if admin && admin.respond_to?(:admin?) && admin.try(:admin?)
        hash[:api_key] = object.user.try(:api_key)
      end

      hash
    end
  end
end
