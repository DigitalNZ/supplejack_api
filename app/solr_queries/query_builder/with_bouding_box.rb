# frozen_string_literal: true

module QueryBuilder
  class WithBoudingBox < Base
    attr_reader :coords

    def initialize(search, coords)
      super(search)

      @coords = coords
    end

    def call
      super
      return search if coords.blank?

      search.build do
        with(:lat_lng).in_bounding_box([coords[2], coords[1]], [coords[0], coords[3]])
      end
    end
  end
end
