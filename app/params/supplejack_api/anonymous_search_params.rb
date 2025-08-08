# frozen_string_literal: true

module SupplejackApi
  class AnonymousSearchParams < SearchParams
    self.max_values = {
      page: 100,
      per_page: 100,
      facets_per_page: 350,
      facets_page: 5000
    }
  end
end
