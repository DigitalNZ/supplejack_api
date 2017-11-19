# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Partner
    include Mongoid::Document

    store_in collection: 'partners', client: 'strong'

    field :name, type: String

    has_many :sources, class_name: 'SupplejackApi::Source'

    validates :name, presence: true
  end
end
