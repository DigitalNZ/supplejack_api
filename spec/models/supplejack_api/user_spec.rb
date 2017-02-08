# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe User do
    let(:user) { User.new }

    before {
      developer = double(:role, name: :developer)
      admin = double(:admin, admin: true)
      allow(RecordSchema).to receive(:default_role) { developer }
      allow(RecordSchema).to receive(:roles) { { admin: admin, developer: developer } }
    }

    describe '#role' do
      it 'should set the default value of the role from the Schema' do
        expect(user.role).to eq 'developer'
      end
    end

    it 'should generate a authentication_token after creating a user' do
      user.save
      user.reload
      expect(user.authentication_token).to_not be_nil
    end

    describe "user_sets" do
      describe "custom_find" do
        it "should lookup the UserSet by Mongo ID" do
          expect(user.user_sets).to receive(:find).with('503a95b112575773920005f4')
          user.user_sets.custom_find('503a95b112575773920005f4')
        end

        it "should lookup the UserSet by URL if param not an ID" do
          expect(user.user_sets).to receive(:where).with(url: 'http://google.com') { [] }
          user.user_sets.custom_find('http://google.com')
        end
      end
    end

    describe "#sets=" do
      it "creates a new set for the user" do
        user.sets = [{name: "Favourites", privacy: "hidden", priority: 0}]
        expect(user.user_sets.size).to eq 1
        expect(user.user_sets.first.name).to eq "Favourites"
        expect(user.user_sets.first.privacy).to eq "hidden"
        expect(user.user_sets.first.priority).to eq 0
      end

      it "doesn't create a new set when the sets are nil" do
        user.sets = nil
        expect(user.user_sets.size).to eq 0
      end
    end

    describe '#name' do
      it "returns the user's name" do
        expect(User.new(name: 'John').name).to eq 'John'
      end

      it 'returns the username when the name is empty' do
        expect(User.new(username: 'ben').name).to eq 'ben'
      end
    end

    describe '#updated_today?' do
      it 'should return true if the user was last updated today' do
        user.updated_at = Time.now.beginning_of_day + 10.seconds
        expect(user.updated_today?).to be_truthy
      end

      it 'should return false when the user was last updated yesterday' do
        user.updated_at = Time.now - 1.day
        expect(user.updated_today?).to be_falsey
      end
    end

    describe '#check_daily_requests' do
      it "should reset daily requests if it wasn't updated today" do
        user.attributes = { updated_at: Time.now-1.day, daily_requests: 100 }
        user.check_daily_requests
        expect(user.daily_requests).to eq 1
      end

      it 'should increment daily requests if it was updated today' do
        user.attributes = { updated_at: Time.now, daily_requests: 100 }
        user.check_daily_requests
        expect(user.daily_requests).to eq 101
      end


      context 'api limit notifications' do
        before {
          @email = double
          allow(SupplejackApi::RequestLimitMailer).to receive(:at90percent) { @email }
        }
          
        it 'should send an email if the user is at 90% daily requests' do
          expect(@email).to receive(:deliver)
          user.attributes = {daily_requests: 89, updated_at: Time.now, max_requests: 100}
          expect(SupplejackApi::RequestLimitMailer).to receive(:at90percent).with(user) {@email}
          user.check_daily_requests
        end

        it 'should not send an email if the user has past 90%' do
          user.attributes = {daily_requests: 90, updated_at: Time.now, max_requests: 100}
          expect(SupplejackApi::RequestLimitMailer).to_not receive(:at90percent).with(user) {@email}
          user.check_daily_requests
        end

        it 'should send an email if the user has reached 100%' do
          expect(@email).to receive(:deliver)
          user.attributes = {daily_requests: 99, updated_at: Time.now, max_requests: 100}
          expect(SupplejackApi::RequestLimitMailer).to receive(:at100percent).with(user) {@email}
          user.check_daily_requests
        end

        it 'should not send an email when the user has past 100%' do
          user.attributes = {daily_requests: 100, updated_at: Time.now, max_requests: 100}
          expect(SupplejackApi::RequestLimitMailer).to_not receive(:at100percent).with(user) {@email}
          user.check_daily_requests
        end
      end
    end

    describe '#increment_daily_requests' do
      it 'should increment daily_requests by 1' do
        user.attributes = { updated_at: Time.now, daily_requests: 100 }
        user.increment_daily_requests
        expect(user.daily_requests).to eq 101
      end

      it 'increments daily requests when is nil' do
        user.attributes = { updated_at: Time.now, daily_requests: nil }
        user.increment_daily_requests
        expect(user.daily_requests).to eq 1
      end
    end

    describe '#update_daily_activity' do
      let(:request) { double(:request, params: { action: ', controller: ' }).as_null_object }

      it 'sets the daily_activity_stored flag to false' do
        allow(request).to receive(:params) { { action: 'index', controller: 'records' } }
        user.update_daily_activity(request)
        expect(user.daily_activity_stored).to be_falsey
      end

      context 'records and search requests' do
        it 'updates the search requests' do
          allow(request).to receive(:params) { { action: 'index', controller: 'records' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['search']['records']).to eq 1
        end

        it 'increases the amount of requests for the day' do
          allow(request).to receive(:params) { {action: 'index', controller: 'records'} }
          user.update_daily_activity(request)
          expect(user.daily_activity['search']['records']).to eq 1

          user.update_daily_activity(request)
          expect(user.daily_activity['search']['records']).to eq 2
        end

        it 'updates the requests for the record details' do
          allow(request).to receive(:params) { {action: 'show', controller: 'records'} }
          user.update_daily_activity(request)
          expect(user.daily_activity['records']['show']).to eq 1
        end

        it 'updates the requests for multiple records' do
          allow(request).to receive(:params) { {action: 'multiple', controller: 'records'} }
          user.update_daily_activity(request)
          expect(user.daily_activity['records']['multiple']).to eq 1
        end

        it 'updates the requests for the source redirect' do
          allow(request).to receive(:params) { {action: 'source', controller: 'records'} }
          user.update_daily_activity(request)
          expect(user.daily_activity['records']['source']).to eq 1
        end
      end
    end

    describe '#reset_daily_activity' do
      it 'nullifies the daily_activity' do
        user.reset_daily_activity
        expect(user.daily_activity).to be_nil
      end

      it 'sets the daily_activity_stored flag to true' do
        user.daily_activity_stored = false
        user.reset_daily_activity
        expect(user.daily_activity_stored).to be_truthy
      end

      it 'resets the daily requests count' do
        user.daily_requests = 100
        user.reset_daily_activity
        expect(user.daily_requests).to eq 0
      end
    end

    describe '#over_limit?' do
      context 'user was updated today' do
        before(:each) do
          user.updated_at = Time.now
        end

        it 'should return true when daily requests is greater than max requests' do
          user.attributes = {daily_requests: 100, max_requests: 99}
          expect(user.over_limit?).to be_truthy
        end

        it 'should return false when daily requests is less than max requests' do
          user.attributes = {daily_requests: 100, max_requests: 110}
          expect(user.over_limit?).to be_falsey
        end
      end

      context "user wasn't updated today" do
        it 'should always return false' do
          user.attributes = {updated_at: Time.now-1.day, daily_requests: 100, max_requests: 99}
          expect(user.over_limit?).to be_falsey
        end
      end
    end

    describe '#calculate_last_30_days_requests' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:user_activity) { FactoryGirl.create(:user_activity, user_id: user.id, total: 5, created_at: Time.now) }

      it 'adds up the totals of the last 30 days' do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now - 5.days)
        expect(user.calculate_last_30_days_requests).to eq 7
      end

      it 'ignores requests older than 30 days' do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now - 31.days)
        expect(user.calculate_last_30_days_requests).to eq 5
      end

      it 'stores the requests in monthly_requests field' do
        user.calculate_last_30_days_requests
        expect(user.monthly_requests).to eq 5
      end
    end

    describe '#requests_per_day' do
      let!(:user) { FactoryGirl.create(:user) }

      before do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 5, created_at: Time.now - 1.day)
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now)
      end

      it 'returns an array with the total requests per day' do
        expect(user.requests_per_day(2)).to eq [5, 2]
      end

      it "returns 0 for days when there isn't any activity" do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 1, created_at: Time.now - 3.day)
        expect(user.requests_per_day(4)).to eq [1, 0, 5, 2]
      end
    end

    describe '#name_or_user' do
      it 'should return the name' do
        user.name = 'Federico'
        expect(user.name_or_user).to eq('Federico')
      end

      it 'should return the username' do
        user.name = ''
        user.username = 'fedegl'
        expect(user.name_or_user).to eq('fedegl')
      end

      it 'should return the first part of the email address from name if email' do
        user.name = 'chris.mcdowall@dia.govt.nz'
        expect(user.name_or_user).to eq('chris.mcdowall')
      end

      it 'should return the first part of the email address from username if email' do
        user.name = ''
        user.username = 'chris.mcdowall@dia.govt.nz'
        expect(user.name_or_user).to eq('chris.mcdowall')
      end
    end

    describe '#find_by_api_key' do
      it 'searches for a user by its api key' do
        expect(User).to receive(:where).with(authentication_token: '1234').and_return([double(:record)])
        User.find_by_api_key('1234')
      end

      it 'returns nil when user not found' do
        allow(User).to receive(:where).and_return([])
        expect(User.find_by_api_key('1234')).to be_nil
      end
    end

    describe '#custom_find' do
      let(:user) { FactoryGirl.create(:user) }

      it 'finds the user by the api_key' do
        expect(User.custom_find(user.api_key)).to eq user
      end

      it 'should raise a error when a record is not found' do
        expect { User.custom_find('sfsdfsdf') }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end

      it 'finds the user by the id' do
        expect(User.custom_find(user.id)).to eq user
      end
    end

    describe "can_change_featured_sets?" do
      context "admin user" do
        before { user.role = 'admin' }

        it "should return true" do
          expect(user.can_change_featured_sets?).to be_truthy
        end
      end

      context "user" do
        it "should return false" do
          expect(user.can_change_featured_sets?).to be_falsey
        end
      end
    end

  end
end
