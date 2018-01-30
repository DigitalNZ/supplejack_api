require 'spec_helper'

describe ApplicationController, type: :controller do
controller do
  include SupplejackApi::Concerns::UserSetsControllerMetrics

  def show
    @user_set = SupplejackApi::UserSet.first
    head :ok
  end

  def create
    @user_set = SupplejackApi::UserSet.first
    head :ok
  end
end

  before do
    create(:user_set_with_set_item)
  end

  describe 'GET#show' do
    it 'creates a user_set_views SupplejackApi::RecordMetric' do
      get :show, params: { id: 1 }
      expect(SupplejackApi::RecordMetric.count).to eq 1
      expect(SupplejackApi::RecordMetric.first.user_set_views).to eq 1
    end
  end

  describe '#create' do
    it 'creates a added_to_user_sets SupplejackApi::RecordMetric' do
      post :create, params: { id: 1 }
      expect(SupplejackApi::RecordMetric.count).to eq 1
      expect(SupplejackApi::RecordMetric.first.added_to_user_sets).to eq 1
    end
  end
end
