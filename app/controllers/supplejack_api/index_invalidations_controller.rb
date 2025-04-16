# frozen_string_literal: true

module SupplejackApi
  class IndexInvalidationsController < SupplejackApplicationController
    respond_to :json

    # GET /index_invalidations/token
    # Returns the current invalidation token
    def token
      render json: { token: IndexInvalidation.current_token }, status: :ok
    end
  end
end
