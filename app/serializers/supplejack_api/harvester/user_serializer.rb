# frozen_string_literal: true

module SupplejackApi
  module Harvester
    class UserSerializer < ActiveModel::Serializer
      attributes :id, :name, :username, :email, :api_key, :role,
                 :max_requests, :monthly_requests, :authentication_token, :daily_requests
    end
  end
end
