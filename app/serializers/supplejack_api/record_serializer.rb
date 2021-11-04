# frozen_string_literal: true

module SupplejackApi
  class RecordSerializer < SupplejackApi::BaseSerializer
    attribute :id
    attribute :next_page,       if: -> { object.next_page.present? }
    attribute :next_record,     if: -> { object.next_record.present? }
    attribute :previous_page,   if: -> { object.previous_page.present? }
    attribute :previous_record, if: -> { object.previous_record.present? }
    has_many :fragments

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
