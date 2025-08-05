# frozen_string_literal: true

module SupplejackApi
  class AnonymousSearchParams < SearchParams
    self.max_values = {
      page: 100,
      per_page: 100
    }
  end
end
