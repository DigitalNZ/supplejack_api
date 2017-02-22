# frozen_string_literal: true
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Source
    include Mongoid::Document
    include ActiveModel::MassAssignmentSecurity

    store_in collection: 'sources', session: 'strong'

    attr_accessible :name, :source_id, :_id, :partner_id, :status

    field :name,        type: String
    field :source_id,   type: String
    field :status, 		type: String, default: 'active'

    belongs_to :partner, class_name: 'SupplejackApi::Partner'

    validates :name, presence: true

    scope :suppressed,  -> { where(status: 'suppressed') }

    # Its not completely random. Its not effiient to run .sample on large collections.
    # Fetches 4 random records from first 100 and last 100
    def random_records(limit)
      records = Record.where('fragments.source_id' => source_id, :status => 'active')

      first_hundred = records.sort('fragments.syndication_date' => 1).limit(100).to_a
      last_hundred = records.sort('fragments.syndication_date' => -1).limit(100).to_a

      (first_hundred | last_hundred).sample(limit)
    end
  end
end
