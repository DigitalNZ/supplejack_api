require 'spec_helper'

describe ApplicationController, type: :controller do
controller do
  include SupplejackApi::Concerns::StoriesMetrics

  def show
    @api_response = { payload:  ::StoriesApi::V3::Presenters::Story.new.call(SupplejackApi::UserSet.first) }
    head :ok
  end

  def create
    head :ok
  end
end

  before do
    create(:story)
  end

  describe 'GET#show' do
    it 'creates a user_set_views SupplejackApi::RecordMetric' do
      get :show, params: { id: 1 }
    end
  end

  describe '#create' do
    it 'creates a added_to_user_sets SupplejackApi::RecordMetric' do
      post :create, params: { id: 1 }
    end
  end
end
