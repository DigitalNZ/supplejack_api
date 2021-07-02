# frozen_string_literal: true

# rubocop:disable Layout/LineLength
RSpec.describe SupplejackApi::CollectionMetric do
  describe '#attributes' do
    let!(:collection_metric) do
      create(:collection_metric,
             searches: 2,
             record_page_views: 10,
             user_set_views: 6,
             user_story_views: 11,
             date: Time.now.utc.yesterday)
    end

    it 'has a date' do
      expect(collection_metric.date).to eq Time.now.utc.yesterday.to_date
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
      expect(collection_metric_two.errors.messages[:display_collection])
        .to include "Display collection field can't be blank."
    end

    it 'cannot have two of the same facets on one day' do
      expect(collection_metric_three.errors.messages[:display_collection]).to include 'is already taken'
    end
  end

  describe '#spawn' do
    let!(:record_metrics_yesterday) do
      create_list(:record_metric,
                  5,
                  page_views: 4,
                  user_set_views: 5,
                  display_collection: 'TAPUHI',
                  user_story_views: 6,
                  added_to_user_sets: 7,
                  source_clickthroughs: 8,
                  appeared_in_searches: 9,
                  added_to_user_stories: 10,
                  date: Time.now.utc.yesterday)
    end

    let!(:record_metrics_tomorrow) do
      create_list(:record_metric,
                  5,
                  date: Time.now.utc.tomorrow,
                  page_views: 11,
                  display_collection: 'TAPUHI',
                  user_set_views: 12,
                  user_story_views: 13,
                  added_to_user_sets: 14,
                  source_clickthroughs: 15,
                  appeared_in_searches: 16,
                  added_to_user_stories: 17)
    end

    context 'without params, defaults to all metrics collected before today' do
      before do
        SupplejackApi::CollectionMetric.spawn
      end

      it 'generates per day collection metrics' do
        todays_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.yesterday)

        expect(todays_collection_metric.searches).to eq record_metrics_yesterday.sum(&:appeared_in_searches)
        expect(todays_collection_metric.record_page_views).to eq record_metrics_yesterday.sum(&:page_views)
        expect(todays_collection_metric.user_set_views).to eq record_metrics_yesterday.sum(&:user_set_views)
        expect(todays_collection_metric.user_story_views).to eq record_metrics_yesterday.sum(&:user_story_views)

        expect(todays_collection_metric.records_added_to_user_sets)
          .to eq record_metrics_yesterday.sum(&:added_to_user_sets)
        expect(todays_collection_metric.records_added_to_user_stories)
          .to eq record_metrics_yesterday.sum(&:added_to_user_stories)

        total_views = record_metrics_yesterday.sum(&:page_views) + record_metrics_yesterday.sum(&:appeared_in_searches) + record_metrics_yesterday.sum(&:user_set_views) + record_metrics_yesterday.sum(&:user_story_views)

        expect(todays_collection_metric.total_views)
          .to eq total_views
      end

      it 'generates all collection metrics' do
        yesterday_other_record_metrics = create_list(:record_metric,
                                                     5,
                                                     page_views: 4,
                                                     user_set_views: 5,
                                                     display_collection: 'OTHER',
                                                     user_story_views: 6,
                                                     added_to_user_sets: 7,
                                                     source_clickthroughs: 8,
                                                     appeared_in_searches: 9,
                                                     added_to_user_stories: 10,
                                                     date: Time.now.utc.yesterday)

        SupplejackApi::CollectionMetric.spawn
        all_metrics = SupplejackApi::CollectionMetric.find_by(display_collection: 'all', date: Time.now.utc.yesterday)

        yesterday_record_metrics = record_metrics_yesterday + yesterday_other_record_metrics

        expect(all_metrics.searches).to eq (yesterday_record_metrics).sum(&:appeared_in_searches)
        expect(all_metrics.record_page_views).to eq (yesterday_record_metrics).sum(&:page_views)
        expect(all_metrics.user_set_views).to eq (yesterday_record_metrics).sum(&:user_set_views)
        expect(all_metrics.user_story_views).to eq (yesterday_record_metrics).sum(&:user_story_views)
        expect(all_metrics.records_added_to_user_sets).to eq (yesterday_record_metrics).sum(&:added_to_user_sets)
        expect(all_metrics.records_added_to_user_stories).to eq (yesterday_record_metrics).sum(&:added_to_user_stories)

        total_views = (yesterday_record_metrics).sum(&:page_views) +
                      (yesterday_record_metrics).sum(&:appeared_in_searches) +
                      (yesterday_record_metrics).sum(&:user_set_views) +
                      (yesterday_record_metrics).sum(&:user_story_views)

        expect(all_metrics.total_views).to eq total_views
      end

      it 'only process record metrics that were created before current day' do
        todays_record_metrics = SupplejackApi::RecordMetric.where(date: Time.now.utc)

        todays_record_metrics.each do |record_metric|
          expect(record_metric.processed_by_collection_metrics).to be_falsey
        end
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
                    added_to_user_stories: 13,
                    date: Time.now.utc.yesterday)

        SupplejackApi::CollectionMetric.spawn

        more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.yesterday)

        expect(more_collection_metric.searches)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:appeared_in_searches)
        expect(more_collection_metric.record_page_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:page_views)
        expect(more_collection_metric.user_set_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_set_views)
        expect(more_collection_metric.user_story_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_story_views)
        expect(more_collection_metric.records_added_to_user_sets)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_sets)
        expect(more_collection_metric.records_added_to_user_stories)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_stories)
        expect(more_collection_metric.total_source_clickthroughs)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:source_clickthroughs)
      end

      it 'does not delete old metrics when it is appending new data' do
        appeared_in_searches = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:appeared_in_searches)
        current_page_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:page_views)
        current_user_set_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_set_views)
        current_user_story_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_story_views)
        current_added_to_user_sets = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_sets)
        current_added_to_user_stories = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_stories)
        current_source_clickthroughs = SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:source_clickthroughs)

        SupplejackApi::RecordMetric.destroy_all

        create_list(:record_metric,
                    5,
                    page_views: 7,
                    user_set_views: 8,
                    display_collection: 'TAPUHI',
                    user_story_views: 9,
                    added_to_user_sets: 10,
                    source_clickthroughs: 11,
                    appeared_in_searches: 12,
                    added_to_user_stories: 13,
                    date: Time.now.utc.yesterday)

        SupplejackApi::CollectionMetric.spawn

        more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.yesterday)

        expect(more_collection_metric.searches)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:appeared_in_searches) + appeared_in_searches
        expect(more_collection_metric.record_page_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:page_views) + current_page_views
        expect(more_collection_metric.user_set_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_set_views) + current_user_set_views
        expect(more_collection_metric.user_story_views)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:user_story_views) + current_user_story_views
        expect(more_collection_metric.records_added_to_user_sets)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_sets) + current_added_to_user_sets
        expect(more_collection_metric.records_added_to_user_stories)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:added_to_user_stories) + current_added_to_user_stories
        expect(more_collection_metric.total_source_clickthroughs)
          .to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.yesterday).sum(:source_clickthroughs) + current_source_clickthroughs
      end
    end

    context 'with date_range, it only creates collection metrics for the given date range' do
      let(:today_and_tomorrow) { Time.now.utc.beginning_of_day..Time.now.utc.tomorrow.end_of_day }
      before do
        SupplejackApi::CollectionMetric.spawn(today_and_tomorrow)
      end

      it 'generates per day collection metrics' do
        todays_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.tomorrow)

        expect(todays_collection_metric.searches).to eq record_metrics_tomorrow.sum(&:appeared_in_searches)
        expect(todays_collection_metric.record_page_views).to eq record_metrics_tomorrow.sum(&:page_views)
        expect(todays_collection_metric.user_set_views).to eq record_metrics_tomorrow.sum(&:user_set_views)
        expect(todays_collection_metric.user_story_views).to eq record_metrics_tomorrow.sum(&:user_story_views)
        expect(todays_collection_metric.records_added_to_user_sets).to eq record_metrics_tomorrow.sum(&:added_to_user_sets)
        expect(todays_collection_metric.records_added_to_user_stories).to eq record_metrics_tomorrow.sum(&:added_to_user_stories)
        expect(todays_collection_metric.total_views).to eq record_metrics_tomorrow.sum(&:page_views) + record_metrics_tomorrow.sum(&:appeared_in_searches) + record_metrics_tomorrow.sum(&:user_set_views) + record_metrics_tomorrow.sum(&:user_story_views)
      end

      it 'generates all collection metrics' do
        other_record_metrics_tomorrow = create_list(:record_metric,
                                                    5,
                                                    page_views: 4,
                                                    user_set_views: 5,
                                                    display_collection: 'OTHER',
                                                    user_story_views: 6,
                                                    added_to_user_sets: 7,
                                                    source_clickthroughs: 8,
                                                    appeared_in_searches: 9,
                                                    added_to_user_stories: 10,
                                                    date: Time.now.utc.tomorrow)

        SupplejackApi::CollectionMetric.spawn(today_and_tomorrow)
        all_metrics = SupplejackApi::CollectionMetric.find_by(display_collection: 'all', date: Time.now.utc.tomorrow)

        tomorrow_record_metrics = other_record_metrics_tomorrow + record_metrics_tomorrow

        expect(all_metrics.searches).to eq (tomorrow_record_metrics).sum(&:appeared_in_searches)
        expect(all_metrics.record_page_views).to eq (tomorrow_record_metrics).sum(&:page_views)
        expect(all_metrics.user_set_views).to eq (tomorrow_record_metrics).sum(&:user_set_views)
        expect(all_metrics.user_story_views).to eq (tomorrow_record_metrics).sum(&:user_story_views)
        expect(all_metrics.records_added_to_user_sets).to eq (tomorrow_record_metrics).sum(&:added_to_user_sets)
        expect(all_metrics.records_added_to_user_stories).to eq (tomorrow_record_metrics).sum(&:added_to_user_stories)
        expect(all_metrics.total_views).to eq (tomorrow_record_metrics).sum(&:page_views) + (tomorrow_record_metrics).sum(&:appeared_in_searches) + (tomorrow_record_metrics).sum(&:user_set_views) + (tomorrow_record_metrics).sum(&:user_story_views)
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
                    added_to_user_stories: 13,
                    date: Time.now.utc.tomorrow)

        SupplejackApi::CollectionMetric.spawn(today_and_tomorrow)

        more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.tomorrow)

        expect(more_collection_metric.searches).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:appeared_in_searches)
        expect(more_collection_metric.record_page_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:page_views)
        expect(more_collection_metric.user_set_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_set_views)
        expect(more_collection_metric.user_story_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_story_views)
        expect(more_collection_metric.records_added_to_user_sets).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_sets)
        expect(more_collection_metric.records_added_to_user_stories).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_stories)
        expect(more_collection_metric.total_source_clickthroughs).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:source_clickthroughs)
      end

      it 'does not delete old metrics when it is appending new data' do
        appeared_in_searches = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:appeared_in_searches)
        current_page_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:page_views)
        current_user_set_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_set_views)
        current_user_story_views = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_story_views)
        current_added_to_user_sets = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_sets)
        current_added_to_user_stories = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_stories)
        current_source_clickthroughs = SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:source_clickthroughs)

        SupplejackApi::RecordMetric.destroy_all

        create_list(:record_metric,
                    5,
                    page_views: 7,
                    user_set_views: 8,
                    display_collection: 'TAPUHI',
                    user_story_views: 9,
                    added_to_user_sets: 10,
                    source_clickthroughs: 11,
                    appeared_in_searches: 12,
                    added_to_user_stories: 13,
                    date: Time.now.utc.tomorrow)

        SupplejackApi::CollectionMetric.spawn(today_and_tomorrow)

        more_collection_metric = SupplejackApi::CollectionMetric.find_by(date: Time.now.utc.tomorrow)

        expect(more_collection_metric.searches).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:appeared_in_searches) + appeared_in_searches
        expect(more_collection_metric.record_page_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:page_views) + current_page_views
        expect(more_collection_metric.user_set_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_set_views) + current_user_set_views
        expect(more_collection_metric.user_story_views).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:user_story_views) + current_user_story_views
        expect(more_collection_metric.records_added_to_user_sets).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_sets) + current_added_to_user_sets
        expect(more_collection_metric.records_added_to_user_stories).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:added_to_user_stories) + current_added_to_user_stories
        expect(more_collection_metric.total_source_clickthroughs).to eq SupplejackApi::RecordMetric.where(date: Time.now.utc.tomorrow).sum(:source_clickthroughs) + current_source_clickthroughs
      end
    end
  end
end
# rubocop:enable Layout/LineLength
