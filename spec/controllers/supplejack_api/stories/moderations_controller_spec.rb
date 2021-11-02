# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  module Stories
    describe ModerationsController do
      routes { SupplejackApi::Engine.routes }

      describe 'with an admin account' do
        before(:each) do
          @user = create(:user, authentication_token: 'abc123')
          allow(RecordSchema).to receive(:roles) { { admin: double(:admin, admin: true) } }
          allow(controller).to receive(:authenticate_user!) { true }
          allow(controller).to receive(:current_user) { @user }
        end

        describe '#index' do
          let!(:user_set1) { create(:user_set, name: 'Name 1', updated_at: Date.parse('2019-1-1')) }
          let!(:user_set2) { create(:user_set, name: 'Name 2', updated_at: Date.parse('2011-1-1')) }
          let!(:user_set3) { create(:user_set, name: 'Name 4', updated_at: Date.parse('2012-1-1')) }
          let!(:user_set4) { create(:user_set, name: 'Name 3', updated_at: Date.parse('2009-1-1')) }

          before :each do
            allow(controller).to receive(:authenticate_admin!) { true }
            @normal_user = double(User, user_sets: []).as_null_object
            allow(User).to receive(:find_by_auth_token).with('nonadminkey') { @normal_user }
          end

          it 'finds all public sets' do
            expect(UserSet).to receive(:moderation_search) { [] }

            get :index, format: 'json'
          end

          it 'renders the public sets as JSON' do
            get :index, format: 'json'
            sets = JSON.parse(response.body)['sets']

            sets.each do |set|
              expect(set).to have_key 'id'
              expect(set).to have_key 'name'
              expect(set).to have_key 'count'
              expect(set).to have_key 'approved'
              expect(set).to have_key 'created_at'
              expect(set).to have_key 'updated_at'
            end
          end

          it 'has total, page, per_page, in its response body' do
            get :index, format: 'json'
            json = JSON.parse(response.body)

            expect(json['per_page']).to eq(10)
            expect(json['page']).to eq(1)
            expect(json['total']).to eq(4)
            expect(json['total_filtered']).to eq(4)
          end

          it 'orders by updated_at asc by default' do
            get :index, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets']).to eq(json['sets'].sort { |s1, s2| s1['updated_at'] <=> s2['updated_at'] })
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(10)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'orders by name asc with the parameter order_by=name' do
            get :index, params: { order_by: :name }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets']).to eq(json['sets'].sort_by { |user_set| user_set['name'] })
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(10)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'orders by name desc by with the parameters order_by=name&direction=desc' do
            get :index, params: { order_by: :name, direction: :desc }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets']).to eq(json['sets'].sort { |s1, s2| s2['name'] <=> s1['name'] })
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(10)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'renders the good 3 sets with parameter per_page=3' do
            get :index, params: { per_page: 3 }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets'].length).to eq(3)
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(3)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'renders the good 3 sets with parameter page=2&per_page=3' do
            get :index, params: { page: 2, per_page: 3 }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets'].length).to eq(1)
            expect(json['sets'][0]).to eq(JSON.parse(StoriesModerationSerializer.new(user_set1).to_json))
            expect(json['page']).to eq(2)
            expect(json['per_page']).to eq(3)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'renders the good set with parameter search=Name 2' do
            get :index, params: { search: 'Name', per_page: 2 }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets'].length).to eq(2)
            expect(json['sets'][0]).to eq(JSON.parse(StoriesModerationSerializer.new(user_set4).to_json))
            expect(json['sets'][1]).to eq(JSON.parse(StoriesModerationSerializer.new(user_set2).to_json))
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(2)
            expect(json['total_filtered']).to eq(4)
            expect(json['total']).to eq(4)
          end

          it 'renders the good 3 sets with parameter search=user_id' do
            get :index, params: { search: user_set3.user_id.to_s }, format: 'json'
            json = JSON.parse(response.body)

            expect(json['sets'].length).to eq(1)
            expect(json['sets'][0]).to eq(JSON.parse(StoriesModerationSerializer.new(user_set3).to_json))
            expect(json['page']).to eq(1)
            expect(json['per_page']).to eq(10)
            expect(json['total_filtered']).to eq(1)
            expect(json['total']).to eq(4)
          end
        end
      end

      describe 'without an admin account' do
        it 'renders the appropriate message' do
          get :index, format: 'json'
          expect(response.body).to eq '{"errors":"You need Administrator privileges to perform this request"}'
        end
      end
    end
  end
end
