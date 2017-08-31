# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UserSetSerializer < ActiveModel::Serializer
    attributes :id, :name, :count, :priority, :featured, :approved
    attributes :created_at, :updated_at, :tags, :privacy, :subjects, :description

    has_one :record
    has_many :items_with_records, key: 'records' do |serializer|
      if serializer.featured?
        object.items_with_records.first
      else
        object.items_with_records.map do |record|
          { record_id: record.record_id, position: record.position }
        end
      end
    end

    attribute :user, if: -> { instance_options[:user] } do
      hash = { name: object.user.try(:name) }
      hash[:api_key] = object.user.api_key if current_user.admin?

      hash
    end

    class SetItemSerializer < ActiveModel::Serializer
      attributes :record_id, :position, *RecordSchema.groups[:sets].fields
    end

    class RecordSerializer < ActiveModel::Serializer
      attribute :record_id
    end

    def featured?
      instance_options[:featured]
    end

  #   def serializable_hash
  #     hash = { id: object.id.to_s }
  #     hash.merge! attributes
  #
  #     options.reverse_merge!(items: true)
  #
  #     include!(:record, node: hash)
  #
  #     if options[:items]
  #       hash[:description] = object.description
  #       hash[:privacy] = object.privacy
  #       hash[:tags] = object.tags
  #       hash[:subjects] = object.subjects
  #       hash[:records] = records
  #     elsif options[:featured]
  #       hash[:records] = records(1)
  #     else
  #       hash[:records] = simple_records
  #     end
  #
  #     hash[:user] = user if options[:user]
  #
  #     hash
  #   end
  #
  #   # Returns a array of Hashes with the information from each record
  #   # included in the Hash
  #   #
  #   # The values to be added from the record are stored in SetItem::ATTRIBUTES
  #   #
  #   def records(amount = nil)
  #     attributes = [:record_id, :position] + RecordSchema.groups[:sets].fields
  #
  #     if options[:fields]
  #       fields = options[:fields].split(',').map(&:to_sym)
  #       # This is done to prevent people from passing random fields and breaking the API
  #       fields.reject! { |field| !SetItem::ATTRIBUTES.include? field }
  #       attributes.concat(fields)
  #     end
  #
  #     object.items_with_records(amount).map do |item|
  #       Hash[attributes.map { |attr| [attr, item.send(attr)] }]
  #     end
  #   end
  #
  #   # Returns a array of Hashes with only the record_id and position
  #   #
  #   def simple_records
  #     object.set_items.map do |item|
  #       { record_id: item.record_id, position: item.position }
  #     end
  #   end
  #
  end
end
