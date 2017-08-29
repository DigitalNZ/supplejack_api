# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class RecordSerializer < ActiveModel::Serializer
    attribute :id
    attribute :next_page, if: -> { object.next_page.present? }
    attribute :next_record, if: -> { object.next_record.present? }
    attribute :previous_page, if: -> { object.previous_page.present? }
    attribute :previous_record, if: -> { object.previous_record.present? }

    RecordSchema.fields.each do |name, definition|
      if definition.search_value.present? && definition.store == false
        attribute name do
          definition.search_value.call(object)
        end
      else
        attribute name do
          if object.public_send(name).nil?
            definition.default_value
          elsif definition.date_format.present?
            format_date(object.public_send(name), definition.date_format)
          else
            object.public_send(name)
          end
        end
      end
    end

    private

    def format_date(date, format)
      date.strftime(format)
    end
  end
end
