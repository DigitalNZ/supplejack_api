# frozen_string_literal: true

module SupplejackApi
  # app/models/supplejack_api/index_invalidation.rb
  class IndexInvalidation
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: 'index_invalidation'

    field :token, type: String, default: -> { SecureRandom.hex(16) }

    # Returns the current token, creating one if it doesn't exist
    def self.current_token
      first_or_create.token
    end

    # Updates the token to a new value
    def self.update_token
      invalidation = first_or_create
      invalidation.update(token: SecureRandom.hex(16))
      invalidation.token
    end
  end
end
