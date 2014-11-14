# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
          controller.stub(:current_admin_user) { user }
        end

        context 'user is a admin' do
          before { user.stub(:admin?) { true } }

          it 'should not do anything' do
            controller.restrict_to_admin_users!.should be_nil
          end
        end

        context 'user is not a admin' do
          before do
            user.stub(:admin?) { false }
            controller.stub(:redirect_to) { nil }
          end

          it 'should sign the user out' do
            controller.should_receive(:sign_out)
            controller.restrict_to_admin_users!
          end

          it 'should redirect the user to the sign in page' do
            controller.should_receive(:redirect_to).with(new_admin_user_session_path, { alert: 'This area is restricted to Administrators' })
            controller.restrict_to_admin_users!
          end
        end
      end

    end
  end
end
