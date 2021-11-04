# frozen_string_literal: true

module SupplejackApi
  # This serialize can be overridden in the consumer api to add custom global attributes to api responses
  # terms_and_conditions is an example
  class BaseSerializer < ActiveModel::Serializer
    # attributes :terms_and_conditions
  end
end
