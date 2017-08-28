# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordSerializer < ActiveModel::Serializer
    # include SupplejackApi::Concerns::RecordSerializable

    RecordSchema.fields.each do |name, definition|
      if definition.search_value.present? && !definition.store
        attribute name do
          definition.search_value.call(object)
        end
      else
        attribute name do
          object.public_send(name)
        end
      end
    end
  end
end
