# frozen_string_literal: true



module SupplejackApi
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :name, :username, :email, :api_key
  end
end
