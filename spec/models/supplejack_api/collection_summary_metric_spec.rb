# frozen_string_literal: true

RSpec.describe SupplejackApi::CollectionSummaryMetric do
  let!(:collection_summary_metric) { create(:collection_summary_metric) }

  describe '#attributes' do
    it 'has a date' do
      expect(collection_summary_metric.date).to eq Time.zone.today
    end

    it 'has a facet' do
      expect(collection_summary_metric.facet).to eq 'TAPHUI'
    end

    it 'has a searches count' do
      expect(collection_summary_metric.searches).to eq 0
    end

    it 'has a record_page_views count' do
      expect(collection_summary_metric.record_page_views).to eq 0
    end

    it 'has a user_set_views count' do
      expect(collection_summary_metric.user_set_views).to eq 0
    end

    it 'has a user_story_views count' do
      expect(collection_summary_metric.user_story_views).to eq 0
    end

    it 'has a total_views count' do
      expect(collection_summary_metric.total_views).to eq 0
    end

    it 'has a records_added_to_user_sets count' do
      expect(collection_summary_metric.records_added_to_user_sets).to eq 0
    end

    it 'has a total_source_clickthroughs count' do
      expect(collection_summary_metric.total_source_clickthroughs).to eq 0
    end
  end

  describe '#validation' do
    let(:collection_summary_metric_two) { build(:collection_summary_metric, facet: nil) }
    let(:collection_summary_metric_three) { build(:collection_summary_metric) }

    before do
      collection_summary_metric_two.valid?
      collection_summary_metric_three.valid?
    end

    it 'requires a facet' do
      expect(collection_summary_metric_two.errors.messages[:facet]).to include "Facet field can't be blank."
    end


    it 'cannot have two of the same facets on one day' do
      expect(collection_summary_metric_three.errors.messages[:facet]).to include 'is already taken'
    end
  end
end
