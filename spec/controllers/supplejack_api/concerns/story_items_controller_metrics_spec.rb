require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    include SupplejackApi::Concerns::StoryItemsControllerMetrics

    def create
      @api_response = { payload: ::StoriesApi::V3::Presenters::Story.new.call(SupplejackApi::UserSet.first)[:contents].first }
      head :ok
    end
  end

  let!(:story) { create(:story) }

  describe '#create' do
    it 'creates a added_to_user_stories SupplejackApi::RequestMetric' do
      post :create, params: { id: 1 }
      expect(SupplejackApi::RequestMetric.count).to eq 1

      expect(SupplejackApi::RequestMetric.first.metric).to eq 'added_to_user_stories'
      expect(SupplejackApi::RequestMetric.first.records.first.values).to include story.set_items.first.record_id
      expect(SupplejackApi::RequestMetric.first.records.first.values).to include story.set_items.first.content[:display_collection]
    end
  end
end
