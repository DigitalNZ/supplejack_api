

require 'spec_helper'

module SupplejackApi
  module Admin
    describe BaseController, type: :controller do
      routes { SupplejackApi::Engine.routes }

      let(:user) { double(User).as_null_object }

      controller(Admin::BaseController) do
        def index
        end
      end

      describe '#restrict_to_admin_users!' do
        before(:each) do
          allow(controller).to receive(:current_admin_user) { user }
        end

        context 'user is a admin' do
          before { allow(user).to receive(:admin?) { true } }

          it 'should not do anything' do
            expect(controller.restrict_to_admin_users!).to be_nil
          end
        end

        context 'user is not a admin' do
          before do
            allow(user).to receive(:admin?) { false }
            allow(controller).to receive(:redirect_to) { nil }
          end

          it 'should sign the user out' do
            expect(controller).to receive(:sign_out)
            controller.restrict_to_admin_users!
          end

          it 'should redirect the user to the sign in page' do
            expect(controller).to receive(:redirect_to).with(new_admin_user_session_path, { alert: 'This area is restricted to Administrators' })
            controller.restrict_to_admin_users!
          end
        end
      end

    end
  end
end
