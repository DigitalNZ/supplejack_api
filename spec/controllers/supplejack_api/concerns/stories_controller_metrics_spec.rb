require 'spec_helper'

describe ApplicationController, type: :controller do
  controller do
    include SupplejackApi::Concerns::StoriesControllerMetrics

    def show
      @api_response = { payload:  ::StoriesApi::V3::Presenters::Story.new.call(SupplejackApi::UserSet.first) }
      head :ok
    end
  end

  let!(:story) { create(:story) }

  describe 'GET#show' do
    it 'creates a user_story_views SupplejackApi::RecordMetric' do
      get :show, params: { id: 1 }

      expect(SupplejackApi::RequestMetric.count).to eq 1
      expect(SupplejackApi::RequestMetric.first.records.map { |x| x[:record_id] }).to eq story.set_items.map(&:record_id)
      expect(SupplejackApi::RequestMetric.first.records.map { |x| x[:display_collection] }).to eq story.set_items.map { |x| x[:content][:display_collection] }
    end
  end
end
