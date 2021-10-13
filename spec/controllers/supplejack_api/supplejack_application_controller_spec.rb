# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SupplejackApplicationController, type: :controller do
    routes { SupplejackApi::Engine.routes }
    let(:user) { create(:user) }

    describe '#current_auth_token' do
      context 'when authentication_token is passed as api_key in params' do
        before { allow(controller).to receive(:params) { { api_key: user.authentication_token } } }

        it 'returns user authentication_token' do
          expect(controller.current_auth_token).to eq user.authentication_token
        end
      end

      context 'when authentication_token is passed as auth_token in request headers' do
        before do
          allow(controller).to receive(:params) { { api_key: nil } }
          allow(controller).to receive(:request) {
            double(:request, headers: { 'auth_token' => user.authentication_token })
          }
        end

        it 'returns user authentication_token' do
          expect(controller.current_auth_token).to eq user.authentication_token
        end
      end
    end

    describe '#current_user' do
      context 'when authenticated with api_key' do
        before { allow(controller).to receive(:params) { { api_key: user.authentication_token } } }

        it 'returns current_user' do
          expect(controller.current_user).to eq user
        end
      end

      context 'when authenticated with auth_token' do
        before do
          allow(controller).to receive(:params) { { api_key: nil } }
          allow(controller).to receive(:request) {
            double(:request, headers: { 'auth_token' => user.authentication_token })
          }
        end

        it 'returns current_user' do
          expect(controller.current_user).to eq user
        end
      end
    end

    describe '#authenticate_user!' do
      context 'when api_key & auth_token is nil' do
        before do
          allow(controller).to receive(:params) { { api_key: nil } }
          allow(controller).to receive(:request) {
            double(:request,
                   ip: '1.1.1.1',
                   format: :json,
                   params: { controller: 'supplejack_api/users' },
                   headers: { 'auth_token' => nil })
          }
        end

        it 'renders blank_token error' do
          expect(controller).to receive(:render).with(
            { json: { errors: I18n.t('users.blank_token') }, status: :forbidden }
          )

          controller.authenticate_user!
        end
      end

      context 'when api_key is invalid' do
        before { allow(controller).to receive(:params) { { api_key: Faker::Internet.password } } }

        it 'renders invalid_token error' do
          expect(controller).to receive(:render).with(
            { json: { errors: I18n.t('users.invalid_token') }, status: :forbidden }
          )

          controller.authenticate_user!
        end
      end

      context 'when user is over daily requests limit' do
        before do
          allow(controller).to receive(:params) { { api_key: user.authentication_token } }
          user.update(daily_requests: 10_000_00)
        end

        it 'returns reached_limit error' do
          expect(controller).to receive(:render).with(
            {
              json: { errors: I18n.t('users.reached_limit') },
              status: :forbidden
            }
          )

          controller.authenticate_user!
        end
      end

      context 'when request is valid' do
        before do
          allow(controller).to receive(:params) { { api_key: user.authentication_token } }
          allow(controller).to receive(:request) {
            double(:request,
                   ip: '1.1.1.1',
                   format: :json,
                   params: { controller: 'supplejack_api/stories', action: 'show' },
                   headers: { 'auth_token' => nil })
          }

          controller.authenticate_user!
        end

        it 'sets current_auth_token' do
          expect(controller.current_auth_token).to eq user.authentication_token
        end

        it 'sets current_user' do
          expect(controller.current_user).to eq user
        end

        it 'updates user sign_in_count' do
          expect(user.sign_in_count).to eq nil

          user.reload

          expect(user.sign_in_count).to eq 1
        end

        it 'updates last_sign_in_at' do
          expect(user.last_sign_in_at).to eq nil

          user.reload

          expect(user.last_sign_in_at).to be > 1.minute.ago
        end

        it 'updates current_sign_in_at' do
          expect(user.current_sign_in_at).to eq nil

          user.reload

          expect(user.current_sign_in_at).to be > 1.minute.ago
        end

        it 'updates last_sign_in_ip' do
          expect(user.last_sign_in_ip).to eq nil

          user.reload

          expect(user.last_sign_in_ip).to eq '1.1.1.1'
        end

        it 'updates current_sign_in_ip' do
          expect(user.last_sign_in_ip).to eq nil

          user.reload

          expect(user.last_sign_in_ip).to eq '1.1.1.1'
        end

        it 'updates daily_requests' do
          expect(user.daily_requests).to eq 0

          user.reload

          expect(user.daily_requests).to eq 1
        end

        it 'updates daily_activity' do
          expect(user.daily_activity).to be nil

          user.reload

          expect(user.daily_activity).to eq({ 'stories' => { 'show' => 1 } })
        end

        it 'updates daily_activity_stored' do
          expect(user.daily_activity_stored).to be true

          user.reload

          expect(user.daily_activity_stored).to be false
        end
      end
    end

    describe '#authenticate_admin!' do
      context 'when user is admin' do
        before do
          allow(controller).to receive(:request) {
            double(:request,
                   ip: '1.1.1.1',
                   format: :json,
                   params: { controller: 'supplejack_api/stories', action: 'show' },
                   headers: { 'auth_token' => create(:admin_user).authentication_token })
          }
        end

        it 'returns true' do
          expect(controller.authenticate_admin!).to be true
        end
      end

      context 'when user is not admin' do
        before do
          allow(controller).to receive(:request) {
            double(:request,
                   ip: '1.1.1.1',
                   format: :json,
                   params: { controller: 'supplejack_api/stories', action: 'show' },
                   headers: { 'auth_token' => user.authentication_token })
          }
        end

        it 'renders requires_admin_privileges error' do
          expect(controller).to receive(:render).with(
            {
              json: { errors: I18n.t('errors.requires_admin_privileges') },
              status: :forbidden
            }
          )

          controller.authenticate_admin!
        end
      end
    end

    describe '#find_user_set' do
      context 'current_user is a admin' do
        before :each do
          @user_set = double(:set).as_null_object
          allow(controller).to receive(:current_user) { double(:user, admin?: true, role: 'admin').as_null_object }
          allow(controller).to receive(:params) { { id: '12345' } }
        end

        it 'finds the set even if its not owned by the current_user' do
          expect(UserSet).to receive(:custom_find).with('12345') { @user_set }

          controller.find_user_set
        end
      end
    end
  end
end
