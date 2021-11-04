# frozen_string_literal: true

module SupplejackApi
  class UserSerializer < SupplejackApi::BaseSerializer
    attributes :id, :name, :username, :email, :api_key
  end
end
