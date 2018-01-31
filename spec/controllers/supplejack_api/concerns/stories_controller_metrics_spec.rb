require 'spec_helper'

describe ApplicationController, type: :controller do
controller do
  include SupplejackApi::Concerns::StoriesControllerMetrics

  def show
    @api_response = { payload:  ::StoriesApi::V3::Presenters::Story.new.call(SupplejackApi::UserSet.first) }
    head :ok
  end
end

  before do
    create(:story)
  end

  describe 'GET#show' do
    it 'creates a user_story_views SupplejackApi::RecordMetric' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::RecordMetric.count).to eq 2
      expect(SupplejackApi::RecordMetric.first.user_story_views).to eq 1
    end
  end
end
