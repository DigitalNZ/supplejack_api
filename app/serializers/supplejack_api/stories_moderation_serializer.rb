# frozen_string_literal: true



module SupplejackApi
  class StoriesModerationSerializer < ActiveModel::Serializer
    attributes :id, :name, :count, :approved, :featured, :created_at, :updated_at, :featured_at, :user_id
  end
end
