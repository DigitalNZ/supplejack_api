# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  FactoryBot.define do
    factory :record_metric, class: SupplejackApi::RecordMetric do
      date                Date.today
      record_id            1
      page_views           1
      user_set_views       1
      added_to_user_sets   1
      source_clickthroughs 1
      appeared_in_searches 1
    end
  end
end
