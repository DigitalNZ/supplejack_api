# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe UserSetsController, type: :controller do
    routes { SupplejackApi::Engine.routes }

    let(:user) { create(:user) }

    before { allow(controller).to receive(:current_user) { user } }

    describe 'GET index' do
      it 'should return all the user sets of the user' do
        expect(controller.current_user).to receive(:user_sets)

        get :index
      end
    end

    describe '#featured_sets_index' do
      context 'authentication succedded' do
        before { allow(controller).to receive(:authenticate_user!) { true } }

        it 'finds 4 public sets' do
          expect(UserSet).to receive(:featured_sets).with(4) { [] }

          get :featured_sets_index, params: { api_key: 'abc123' }, format: 'json'
        end
      end
    end

    describe 'GET show' do
      let(:user_set) { build(:user_set) }

      it 'finds the user_set' do
        expect(UserSet).to receive(:custom_find).with(user_set.id.to_s) { user_set }

        get :show, params: { id: user_set.id.to_s }
      end

      it 'returns a 404 error when the set is not found' do
        allow(UserSet).to receive(:custom_find) { nil }
        get :show, params: { id: user_set.id.to_s }

        expect(response.code).to eq('404')
        expect(response.body).to eq({ errors: I18n.t('errors.user_set_not_found', id: user_set.id.to_s) }.to_json)
      end
    end

    describe 'POST create' do
      let(:user_set) { build(:user_set) }

      before do
        allow(controller.current_user.user_sets).to receive(:build) { user_set }
        create(:record, record_id: 123_45)
      end

      it 'should build a new set with the params' do
        expect(controller.current_user.user_sets).to receive(:build) { user_set }
        expect(user_set).to receive(:update_attributes_and_embedded)
          .with({ name: 'Dogs', description: 'Ugly', privacy: 'hidden' })

        post :create, params: { set: { name: 'Dogs', description: 'Ugly', privacy: 'hidden' } }
      end

      it 'saves the user set' do
        post :create, params: { set: { name: 'A new set for dnz' } }

        expect(SupplejackApi::UserSet.last.name).to eq 'A new set for dnz'
      end

      it 'returns a 422 error when the set is invalid' do
        allow(user_set).to receive(:update_attributes_and_embedded) { false }
        allow(user_set).to receive(:errors).and_return({ name: ["can't be blank"] })
        post :create, params: { set: {} }

        expect(response.code).to eq('422')
        expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
      end

      it 'rescues from a :records format error and renders the error' do
        allow(user_set).to receive(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
        post :create, params: { set: {} }

        expect(response.code).to eq('422')
        expect(response.body).to eq({ errors: { records: ['The records array is not in a valid format.'] } }.to_json)
      end
    end

    describe 'PUT update' do
      let(:user_set) { create(:user_set, user_id: user.id) }

      before { allow(user_set).to receive(:update_attributes_and_embedded) { true } }

      context 'normal operations' do
        before do
          allow(controller.current_user.user_sets).to receive(:custom_find) { user_set }
        end

        it 'finds the user_set through the user' do
          expect(controller.current_user.user_sets).to receive(:custom_find).with(user_set.id.to_s) { user_set }

          put :update, params: { id: user_set.id.to_s, set: { records: [{ record_id: 13, position: 2 }] } }
        end

        it 'returns a 404 error when the set is not found' do
          allow(controller.current_user.user_sets).to receive(:custom_find) { nil }
          put :update, params: { id: user_set.id.to_s }

          expect(response.code).to eq('404')
          expect(response.body).to eq({ errors: "UserSet with id: #{user_set.id} was not found." }.to_json)
        end

        it 'updates the attributes of the user_set' do
          expect(user_set).to receive(:update_attributes_and_embedded)
            .with({ records: [{ record_id: '13', position: '2' }] }, user)

          put :update, params: { id: user_set.id.to_s, set: { records: [{ record_id: 13, position: 2 }] } }
        end

        it 'updates the approved attribute of a user_set' do
          # Rails 5 converts boolean params to string, which has no affect on mongo result
          expect(user_set).to receive(:update_attributes_and_embedded).with({ approved: 'true' }, user)

          put :update, params: { id: user_set.id.to_s, set: { approved: true } }
        end

        it 'returns a 406 error when the set is invalid' do
          allow(user_set).to receive(:update_attributes_and_embedded) { false }
          allow(user_set).to receive(:errors).and_return({ name: ["can't be blank"] })

          post :update, params: { id: user_set.id.to_s, set: { name: nil } }

          expect(response.code).to eq('422')
          expect(response.body).to eq({ errors: { name: ["can't be blank"] } }.to_json)
        end

        it 'rescues from a :records format error and renders the error' do
          allow(user_set).to receive(:update_attributes_and_embedded).and_raise(UserSet::WrongRecordsFormat)
          post :update, params: { id: user_set.id.to_s, set: { name: nil } }

          expect(response.code).to eq('422')
          expect(response.body).to eq({ errors: { records: ['The records array is not in a valid format.'] } }.to_json)
        end
      end
    end

    describe 'DELETE destroy' do
      let(:user_set) { create(:user_set, user_id: user.id) }

      before { allow(controller.current_user.user_sets).to receive(:custom_find) { user_set } }

      it 'returns a 404 error when the set is not found' do
        allow(controller.current_user.user_sets).to receive(:custom_find) { nil }
        delete :destroy, params: { id: user_set.id.to_s }

        expect(response.code).to eq('404')
        expect(response.body).to eq({ errors: "UserSet with id: #{user_set.id} was not found." }.to_json)
      end

      it 'finds the user_set through the user' do
        expect(controller.current_user.user_sets).to receive(:custom_find).with(user_set.id.to_s) { user_set }

        delete :destroy, params: { id: user_set.id.to_s }, format: :json
      end

      it 'deletes the user set' do
        expect(user_set).to receive(:destroy)

        delete :destroy, params: { id: user_set.id.to_s }, format: :json
      end
    end
  end
end
