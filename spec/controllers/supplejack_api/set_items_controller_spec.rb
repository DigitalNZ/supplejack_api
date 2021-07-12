# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SetItemsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:user)     { create(:user) }
    let(:user_set) { create(:user_set_with_set_item) }
    let(:set_item) { user_set.set_items.first }

    before do
      allow(controller).to receive(:authenticate_user!) { true }
      allow(controller).to receive(:current_user) { user }
      allow(controller.current_user.user_sets).to receive(:custom_find) { user_set }
    end

    describe 'POST create' do
      it 'creates the set item through the user_set' do
        record = create(:record_with_fragment)
        rec = { record_id: record.record_id.to_s, type: 'embed', sub_type: 'record',
                content: { record_id: record.record_id.to_s },
                meta: { align_mode: 0 } }

        expect(user_set.set_items).to receive(:build).with(rec) { set_item }
        expect(user_set).to receive(:save).and_return(true)
        post :create, params: { user_set_id: user_set.id, record: { record_id: record.record_id } }, format: :json
      end
    end

    describe 'DELETE destroy' do
      before { allow(user_set.set_items).to receive(:find_by_record_id) { set_item } }

      it 'finds the set_item through the user_set' do
        expect(user_set.set_items).to receive(:find_by_record_id).with('12')
        delete :destroy, params: { user_set_id: user_set.id, id: '12' }, format: :json
      end

      it 'destroys the set_item' do
        expect(set_item).to receive(:destroy)
        delete :destroy, params: { user_set_id: user_set.id, id: '12' }, format: :json
      end

      context 'it doesn\'t find the set_item' do
        before { allow(user_set.set_items).to receive(:find_by_record_id) { nil } }

        it 'returns a 404' do
          delete :destroy, params: { user_set_id: user_set.id, id: '12' }
          expect(response.code).to eq '404'
          expect(response.body).to eq({ errors: I18n.t('errors.record_not_found', id: '12') }.to_json)
        end
      end
    end
  end
end
