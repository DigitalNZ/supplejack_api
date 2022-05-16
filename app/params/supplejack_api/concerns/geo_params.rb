# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module GeoParams
      attr_reader :geo_bbox

      private

      def init_geo_bbox(geo_bbox: '', **_)
        @geo_bbox = geo_bbox.split(',').map(&:to_f)
      end
    end
  end
end
