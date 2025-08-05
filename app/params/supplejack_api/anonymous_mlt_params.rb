# frozen_string_literal: true

module SupplejackApi
  class AnonymousMltParams < MltParams
    self.max_values = {
      page: 100,
      per_page: 100
    }
  end
end
