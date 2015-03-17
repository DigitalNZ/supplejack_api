# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  module Admin
    describe SiteActivitiesController, type: :controller do
      routes { SupplejackApi::Engine.routes }
      
      let(:site_activity) { double(SiteActivity).as_null_object }
      let(:user) { double(User).as_null_object }

      before(:each) do
        allow(controller).to receive(:current_admin_user) { user }
        allow(controller).to receive(:authenticate_admin_user!) { true }
      end
      
      describe 'GET index' do
        before { allow(SiteActivity).to receive(:sortable) { [site_activity] } }

        it 'finds all site activities' do
          get :index
          expect(assigns(:site_activities)).to eq [site_activity]
        end

        it 'sorts the site activities by the order param' do
          expect(SiteActivity).to receive(:sortable).with(hash_including(order: 'total_asc'))
          get :index, order: 'total_asc'
        end

        it 'paginates the site activities' do
          expect(SiteActivity).to receive(:sortable).with(hash_including(page: '2'))
          get :index, page: 2
        end
      end
    end
  end
end