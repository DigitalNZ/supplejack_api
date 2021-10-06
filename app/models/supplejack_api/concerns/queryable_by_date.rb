# frozen_string_literal: true

module SupplejackApi
  module Concerns
    # Contains convenience methods for querying documents by their day field
    # This concern assumes documents have the field 'day' of type +Date+
    module QueryableByDate
      extend ActiveSupport::Concern

      included do
        index({ date: 1 }, background: true)
      end

      module ClassMethods
        def created_on(date)
          where(:date.gte => date.at_beginning_of_day, :date.lte => date.at_end_of_day)
        end

        def created_between(start_date, end_date)
          where(:date.gte => start_date,
                :date.lte => end_date)
        end
      end
    end
  end
end
