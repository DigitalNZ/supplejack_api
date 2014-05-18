# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  module Sortable

    module Criteria
      def sort_order(order)
        if order.to_s =~ /^([\w\_\.]+)_(desc|asc)$/
          self.order_by("#{$1} #{$2}")
        else
          self
        end
      end
    end

    module Query
      extend ActiveSupport::Concern

      module ClassMethods
        def sortable(options={})
          options = options.try(:symbolize_keys) || {}
          options[:page] ||= 1
          options[:per_page] ||= 25

          scope = self.unscoped
          scope = scope.sort_order(options[:order]) if options[:order]
          scope = scope.page(options[:page]).per(options[:per_page])
          scope
        end
      end
    end

  end
end

Mongoid::Criteria.send(:include, SupplejackApi::Sortable::Criteria)