# frozen_string_literal: true



# method String#to_a was removed in Mongoid 4
# reference: https://github.com/mongoid/mongoid/commit/db84c0972bf4f01019cdfc2e9ab647fb814d3224

module Mongoid
  module Extensions
    module String
      def to_a
        [self]
      end
    end
  end
end
