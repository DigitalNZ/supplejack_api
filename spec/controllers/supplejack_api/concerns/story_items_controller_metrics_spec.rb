require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    include SupplejackApi::Concerns::StoryItemsControllerMetrics

    def create
      @api_response = { payload: ::StoriesApi::V3::Presenters::Story.new.call(SupplejackApi::UserSet.first)[:contents].first }
      head :ok
    end
  end

  before do
    create(:story)
  end

  describe '#create' do
    it 'creates a added_to_user_stories SupplejackApi::RecordMetric' do
      post :create, params: { id: 1 }
      expect(SupplejackApi::RecordMetric.count).to eq 1
      expect(SupplejackApi::RecordMetric.first.added_to_user_stories).to eq 1
    end
  end
end
