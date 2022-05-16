# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module WithoutParams
      attr_reader :without

      private

      def init_without(without: {}, **_)
        @without = without.map do |name, values|
          values = values.split(',') if values.instance_of?(String)
          [name, values.map { |value| self.class.cast_param(name, value) }.compact]
        end.to_h
      end
    end
  end
end
