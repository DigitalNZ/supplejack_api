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

      included do
        # Returns:
        # - the default value if no value is provided
        # - the corresponding max value if it is exceeding it
        # - the value otherwise
        def integer_param(param, value)
          if param == :page && self.class.max_values[param] == 100 && self.class.max_values[param] < value
              # rubocop:disable Layout/LineLength
              errors << "The #{param} parameter for anonymous users (without an API key) can not exceed #{self.class.max_values[param]}"
              # rubocop:enable Layout/LineLength
          end

          if self.class.max_values[param] < value
            errors << "The #{param} parameter can not exceed #{self.class.max_values[param]}"
          end

          value = value.to_i
          value = [value, self.class.max_values[param]].min if self.class.max_values[param]
          value
        end
      end
    end
  end
end
