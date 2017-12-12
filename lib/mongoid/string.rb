# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
