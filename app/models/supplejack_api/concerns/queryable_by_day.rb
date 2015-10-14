# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Concerns
    # Contains convenience methods for querying documents by their day field
    # This concern assumes documents have the field 'day' of type +Date+
    module QueryableByDay
      extend ActiveSupport::Concern

      module ClassMethods
        def created_on(date)
          where(:day.gte => date.at_beginning_of_day, :day.lte => date.at_end_of_day)
        end

        def created_between(start_date, end_date)
          where(:day.gte => start_date, :day.lte => end_date)
        end
      end
    end
  end
end
