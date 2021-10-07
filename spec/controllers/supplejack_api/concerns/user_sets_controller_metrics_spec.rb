# frozen_string_literal: true

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

  describe 'GET#show' do
    context 'active record' do
      before { create(:user_set_with_set_item) }

      it 'creates a user_set_views SupplejackApi::RequestMetric' do
        get :show, params: { id: 1 }

        expect(SupplejackApi::RequestMetric.count).to eq 1
        expect(SupplejackApi::RequestMetric.first.metric).to eq 'user_set_views'
        expect(SupplejackApi::RequestMetric.first.records).to eq [{ 'record_id' => 2, 'display_collection' => 'test' }]
      end
    end

    context 'deleted record' do
      before do
        deleted_user_set = create(:user_set_with_set_item)
        SupplejackApi::Record
                     .custom_find(deleted_user_set.set_items.first.record_id)
                     .update(status: 'deleted')
      end

      it 'does not die when requesting a record that has status deleted' do
        get :show, params: { id: 1 }

        expect(SupplejackApi::RequestMetric.count).to eq 0
      end
    end
  end

  describe '#create' do
    context 'active record' do
      before { create(:user_set_with_set_item) }

      it 'creates a added_to_user_sets SupplejackApi::RequestMetric' do
        post :create, params: { id: 1 }

        expect(SupplejackApi::RequestMetric.count).to eq 1
        expect(SupplejackApi::RequestMetric.first.records).to eq [{ 'record_id' => 2, 'display_collection' => 'test' }]
        expect(SupplejackApi::RequestMetric.first.metric).to eq 'added_to_user_sets'
      end
    end

    context 'deleted record' do
      before do
        deleted_user_set = create(:user_set_with_set_item)
        SupplejackApi::Record
                     .custom_find(deleted_user_set.set_items.first.record_id)
                     .update(status: 'deleted')
      end

      it 'does not die when requesting a record that has status deleted' do
        post :create, params: { id: 1 }

        expect(SupplejackApi::RequestMetric.count).to eq 0
      end
    end
  end
end
