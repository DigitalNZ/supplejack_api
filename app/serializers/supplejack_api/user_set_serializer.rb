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
    has_many :items_with_records, key: :records do |serializer|
      if serializer.featured?
        object.items_with_records.first
      elsif serializer.full_set_items?
        object.items_with_records
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

    def full_set_items?
      instance_options[:full_set_items]
    end
  end
end
