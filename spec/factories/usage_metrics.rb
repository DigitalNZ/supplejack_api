
module SupplejackApi
  FactoryBot.define do
    factory :usage_metrics, class: SupplejackApi::UsageMetrics do
			record_field_value         "Voyager 1"
			searches                   1
			gets                       1
			user_set_views             1
			total_views                1
      records_added_to_user_sets 1
      date                       Time.now.utc.to_date
    end
  end
end
