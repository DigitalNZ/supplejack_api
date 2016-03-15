# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https//github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http//digitalnz.org/supplejack

module SupplejackApi
  FactoryGirl.define do
    factory :usage_metrics, class: SupplejackApi::UsageMetrics do
			record_field_value         "Voyager 1"
			searches                   1
			gets                       1
			user_set_views             1
			total_views                1
      records_added_to_user_sets 1
      date                       Date.current
    end
  end
end
