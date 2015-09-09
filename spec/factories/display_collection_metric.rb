require 'faker'

module SupplejackApi
  FactoryGirl.define do
    factory :display_collection_metric, class: SupplejackApi::DisplayCollectionMetric do
      total_active_records 10
      total_new_records 1
      sequence(:name) {|n| "Display collection #{n}"}
      category_counts do
        {
          'category-1' => 1,
          'category-2' => 2
        }
      end

      copyright_counts do 
        {
          'copyright-1' => 1,
          'copyright-2' => 2
        }
      end
    end
  end
end
