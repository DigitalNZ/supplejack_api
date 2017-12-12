# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class UsageMetrics
    include Mongoid::Document
    include Mongoid::Timestamps
    include SupplejackApi::Concerns::QueryableByDate

    store_in collection: 'usage_metrics'

    field :record_field_value,         type: String
    field :searches,         	         type: Integer, default: 0
    field :gets,             	         type: Integer, default: 0
    field :user_set_views,   	         type: Integer, default: 0
    field :total_views,                type: Integer, default: 0
    field :records_added_to_user_sets, type: Integer, default: 0
    field :date,                       type: Date
  end
end
