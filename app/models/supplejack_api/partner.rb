# frozen_string_literal: true



module SupplejackApi
  class Partner
    include Mongoid::Document

    store_in collection: 'partners', client: 'strong'

    field :name, type: String

    has_many :sources, class_name: 'SupplejackApi::Source', dependent: :destroy

    validates :name, presence: true
  end
end
