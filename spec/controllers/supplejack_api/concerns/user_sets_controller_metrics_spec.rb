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
      before do
        create(:user_set_with_set_item)
      end

      it 'creates a user_set_views SupplejackApi::RecordMetric' do
        get :show, params: { id: 1 }
        expect(SupplejackApi::RecordMetric.count).to eq 1
        expect(SupplejackApi::RecordMetric.first.user_set_views).to eq 1
      end
    end

    context 'deleted record' do
      before do
        deleted_user_set = create(:user_set_with_set_item)
        SupplejackApi::Record.custom_find(deleted_user_set.set_items.first.record_id).update_attributes(status: 'deleted')
      end

      it 'does not die when requesting a record that has status deleted' do
        get :show, params: { id: 1 }
        expect(SupplejackApi::RecordMetric.count).to eq 0
      end
    end
  end

  describe '#create' do
    context 'active record' do
      before do
        create(:user_set_with_set_item)
      end

      it 'creates a added_to_user_sets SupplejackApi::RecordMetric' do
        post :create, params: { id: 1 }
        expect(SupplejackApi::RecordMetric.count).to eq 1
        expect(SupplejackApi::RecordMetric.first.added_to_user_sets).to eq 1
      end
    end

    context 'deleted record' do
      before do
        deleted_user_set = create(:user_set_with_set_item)
        SupplejackApi::Record.custom_find(deleted_user_set.set_items.first.record_id).update_attributes(status: 'deleted')
      end

      it 'does not die when requesting a record that has status deleted' do
        post :create, params: { id: 1 }
        expect(SupplejackApi::RecordMetric.count).to eq 0
      end
    end
  end
end
