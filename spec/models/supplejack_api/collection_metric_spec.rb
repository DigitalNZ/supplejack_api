# frozen_string_literal: true

RSpec.describe SupplejackApi::CollectionMetric do

  describe '#attributes' do
    let!(:collection_metric) { create(:collection_metric, searches: 2, record_page_views: 10, user_set_views: 6, user_story_views: 11 ) }

    it 'has a date' do
      expect(collection_metric.date).to eq Time.zone.now.utc.to_date
    end

    it 'has a facet' do
      expect(collection_metric.display_collection).to eq 'TAPHUI'
    end

    it 'has a searches count' do
      expect(collection_metric.searches).to eq 2
    end

    it 'has a record_page_views count' do
      expect(collection_metric.record_page_views).to eq 10
    end

    it 'has a user_set_views count' do
      expect(collection_metric.user_set_views).to eq 6
    end

    it 'has a user_story_views count' do
      expect(collection_metric.user_story_views).to eq 11
    end

    it 'has a total_views count' do
      expect(collection_metric.total_views).to eq 29
    end

    it 'has a records_added_to_user_sets count' do
      expect(collection_metric.records_added_to_user_sets).to eq 0
    end

    it 'has a total_source_clickthroughs count' do
      expect(collection_metric.total_source_clickthroughs).to eq 0
    end
  end

  describe '#validation' do
    let!(:collection_metric) { create(:collection_metric) }
    let(:collection_metric_two) { build(:collection_metric, display_collection: nil) }
    let(:collection_metric_three) { build(:collection_metric) }

    before do
      collection_metric_two.valid?
      collection_metric_three.valid?
    end

    it 'requires a facet' do
      expect(collection_metric_two.errors.messages[:display_collection]).to include "Display collection field can't be blank."
    end


    it 'cannot have two of the same facets on one day' do
      expect(collection_metric_three.errors.messages[:display_collection]).to include 'is already taken'
    end
  end

  describe '#spawn' do
    let!(:record_metrics_today) { create_list(:record_metric, 5, page_views: 4, user_set_views: 5, display_collection: 'TAPUHI', user_story_views: 6, added_to_user_sets: 7, source_clickthroughs: 8, appeared_in_searches: 9, added_to_user_stories: 10) }

    let!(:record_metrics_tomorrow) { create_list(:record_metric, 5, date: 1.day.from_now.utc, page_views: 11, display_collection: 'TAPUHI', user_set_views: 12, user_story_views: 13, added_to_user_sets: 14, source_clickthroughs: 15, appeared_in_searches: 16, added_to_user_stories: 17) }

    before do
      SupplejackApi::CollectionMetric.spawn
    end

    it 'generates per day collection metrics' do
      todays_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc)

      expect(todays_collection_metric.searches).to eq 45
      expect(todays_collection_metric.record_page_views).to eq 20
      expect(todays_collection_metric.user_set_views).to eq 25
      expect(todays_collection_metric.user_story_views).to eq 30
      expect(todays_collection_metric.total_views).to eq 120
      expect(todays_collection_metric.records_added_to_user_sets).to eq 35
      expect(todays_collection_metric.records_added_to_user_stories).to eq 50
    end

    it 'generates all available SupplejackApi::CollectionMetric days' do
      tomorrows_collection_metric = SupplejackApi::CollectionMetric.find_by(date: 1.day.from_now.utc)

      expect(tomorrows_collection_metric.searches).to eq 80
      expect(tomorrows_collection_metric.record_page_views).to eq 55
      expect(tomorrows_collection_metric.user_set_views).to eq 60
      expect(tomorrows_collection_metric.user_story_views).to eq 65
      expect(tomorrows_collection_metric.total_views).to eq 260
      expect(tomorrows_collection_metric.records_added_to_user_sets).to eq 70
      expect(tomorrows_collection_metric.records_added_to_user_stories).to eq 85
    end

    it 'updates CollectionMetric models if they already exist' do
      create_list(:record_metric,
                  5,
                  page_views: 7,
                  user_set_views: 8,
                  display_collection: 'TAPUHI',
                  user_story_views: 9,
                  added_to_user_sets: 10,
                  source_clickthroughs: 11,
                  appeared_in_searches: 12,
                  added_to_user_stories: 13
                 )

      SupplejackApi::CollectionMetric.spawn

      more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc)

      expect(more_collection_metric.searches).to eq 105
      expect(more_collection_metric.record_page_views).to eq 55
      expect(more_collection_metric.user_set_views).to eq 65
      expect(more_collection_metric.user_story_views).to eq 75
      expect(more_collection_metric.records_added_to_user_sets).to eq 85
      expect(more_collection_metric.records_added_to_user_stories).to eq 115
      expect(more_collection_metric.total_source_clickthroughs).to eq 95
    end

    it 'does not delete old metrics when it is appending new data' do
      SupplejackApi::RecordMetric.destroy_all

      create_list(:record_metric, 5, page_views: 7, user_set_views: 8, display_collection: 'TAPUHI', user_story_views: 9, added_to_user_sets: 10, source_clickthroughs: 11, appeared_in_searches: 12, added_to_user_stories: 13)

      SupplejackApi::CollectionMetric.spawn

      more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc)

      expect(more_collection_metric.searches).to eq 105
      expect(more_collection_metric.record_page_views).to eq 55
      expect(more_collection_metric.user_set_views).to eq 65
      expect(more_collection_metric.user_story_views).to eq 75
      expect(more_collection_metric.records_added_to_user_sets).to eq 85
      expect(more_collection_metric.records_added_to_user_stories).to eq 115
      expect(more_collection_metric.total_source_clickthroughs).to eq 95
    end
  end
end
