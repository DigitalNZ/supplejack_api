# frozen_string_literal: true

RSpec.describe SupplejackApi::CollectionMetric do
  let!(:collection_metric) { create(:collection_metric) }

  describe '#attributes' do
    it 'has a date' do
      expect(collection_metric.date).to eq Time.zone.today
    end

    it 'has a facet' do
      expect(collection_metric.display_collection).to eq 'TAPHUI'
    end

    it 'has a searches count' do
      expect(collection_metric.searches).to eq 0
    end

    it 'has a record_page_views count' do
      expect(collection_metric.record_page_views).to eq 0
    end

    it 'has a user_set_views count' do
      expect(collection_metric.user_set_views).to eq 0
    end

    it 'has a user_story_views count' do
      expect(collection_metric.user_story_views).to eq 0
    end

    it 'has a total_views count' do
      expect(collection_metric.total_views).to eq 0
    end

    it 'has a records_added_to_user_sets count' do
      expect(collection_metric.records_added_to_user_sets).to eq 0
    end

    it 'has a total_source_clickthroughs count' do
      expect(collection_metric.total_source_clickthroughs).to eq 0
    end
  end

  describe '#validation' do
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
    it 'spawns CollectionSummaryMetrics for each display_collection that we have on the current day' do

    end
  end
end
