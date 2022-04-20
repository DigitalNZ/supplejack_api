# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module HelpersParams
      extend ActiveSupport::Concern

      class_methods do
        def cast_param(_name, value)
          return false if value == 'false'
          return true if value == 'true'
          return nil if %w[nil null].include?(value)

          value = value.strip if value.is_a?(String)
          value
        end
      end

      private

      included do
        # Returns:
        # - the default value if no value is provided
        # - the corresponding max value if it is exceeding it
        # - the value otherwise
        def integer_param(param, value)
          value = value.to_i
          value = [value, self.class.max_values[param]].min if self.class.max_values[param]
          value
        end
      end
    end
  end
end
