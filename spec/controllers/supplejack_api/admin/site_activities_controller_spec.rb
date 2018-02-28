

require 'spec_helper'

module SupplejackApi
  module Admin
    describe SiteActivitiesController, type: :controller do
      routes { SupplejackApi::Engine.routes }

      let(:site_activity) { double(SupplejackApi::SiteActivity).as_null_object }
      let(:user) { double(User).as_null_object }

      before(:each) do
        allow(controller).to receive(:current_admin_user) { user }
        allow(controller).to receive(:authenticate_admin_user!) { true }
      end

      describe 'GET index' do
        before { allow(SupplejackApi::SiteActivity).to receive_message_chain(:sortable, :order_by) { [site_activity] } }

        it 'finds all site activities' do
          get :index
          expect(assigns(:site_activities)).to eq [site_activity]
        end

        it 'sorts the site activities by the order param' do
          expect(SupplejackApi::SiteActivity).to receive(:sortable).with(hash_including(order: 'total_asc'))
          get :index, params: { order: 'total_asc' }
        end

        it 'paginates the site activities' do
          expect(SupplejackApi::SiteActivity).to receive(:sortable).with(hash_including(page: '2'))
          get :index, params: { page: 2 }
        end
      end
    end
  end
end