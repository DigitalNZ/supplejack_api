# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe User do
    let(:user) { User.new }

    before do
      developer = double(:role, name: :developer)
      admin = double(:admin, admin: true)
      allow(RecordSchema).to receive(:default_role) { developer }
      allow(RecordSchema).to receive(:roles) { { admin:, developer: } }
    end

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

    describe '#name' do
      it 'returns the users name' do
        expect(User.new(name: 'John').name).to eq 'John'
      end

      it 'returns the username when the name is empty' do
        expect(User.new(username: 'ben').name).to eq 'ben'
      end
    end

    describe '#updated_today?' do
      it 'should return true if the user was last updated today' do
        user.updated_at = Time.now.utc.beginning_of_day + 10.seconds
        expect(user.updated_today?).to be_truthy
      end

      it 'should return false when the user was last updated yesterday' do
        user.updated_at = Time.now.utc - 1.day
        expect(user.updated_today?).to be_falsey
      end
    end

    describe '#check_daily_requests' do
      it 'should reset daily requests if it wasnt updated today' do
        user.attributes = { updated_at: Time.now.utc - 1.day, daily_requests: 100 }
        user.check_daily_requests
        expect(user.daily_requests).to eq 1
      end

      it 'should increment daily requests if it was updated today' do
        user.attributes = { updated_at: Time.now.utc, daily_requests: 100 }
        user.check_daily_requests
        expect(user.daily_requests).to eq 101
      end

      context 'api limit notifications' do
        before do
          @email = double
          allow(SupplejackApi::RequestLimitMailer).to receive(:at90percent) { @email }
        end

        it 'should send an email if the user is at 90% daily requests' do
          expect(@email).to receive(:deliver_now)
          user.attributes = { daily_requests: 89, updated_at: Time.now.utc, max_requests: 100 }
          expect(SupplejackApi::RequestLimitMailer).to receive(:at90percent).with(user) { @email }
          user.check_daily_requests
        end

        it 'should not send an email if the user has past 90%' do
          user.attributes = { daily_requests: 90, updated_at: Time.now.utc, max_requests: 100 }
          expect(SupplejackApi::RequestLimitMailer).to_not receive(:at90percent).with(user) { @email }
          user.check_daily_requests
        end

        it 'should send an email if the user has reached 100%' do
          expect(@email).to receive(:deliver_now)
          user.attributes = { daily_requests: 99, updated_at: Time.now.utc, max_requests: 100 }
          expect(SupplejackApi::RequestLimitMailer).to receive(:at100percent).with(user) { @email }
          user.check_daily_requests
        end

        it 'should not send an email when the user has past 100%' do
          user.attributes = { daily_requests: 100, updated_at: Time.now.utc, max_requests: 100 }
          expect(SupplejackApi::RequestLimitMailer).to_not receive(:at100percent).with(user) { @email }
          user.check_daily_requests
        end
      end
    end

    describe '#increment_daily_requests' do
      it 'should increment daily_requests by 1' do
        user.attributes = { updated_at: Time.now.utc, daily_requests: 100 }
        user.increment_daily_requests
        expect(user.daily_requests).to eq 101
      end

      it 'increments daily requests when is nil' do
        user.attributes = { updated_at: Time.now.utc, daily_requests: nil }
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
          allow(request).to receive(:params) { { action: 'index', controller: 'records' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['search']['records']).to eq 1

          user.update_daily_activity(request)
          expect(user.daily_activity['search']['records']).to eq 2
        end

        it 'increments user_sets view for the day' do
          allow(request).to receive(:params) { { action: 'show', controller: 'set_items' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['user_sets']['show_item']).to eq 1

          user.update_daily_activity(request)
          expect(user.daily_activity['user_sets']['show_item']).to eq 2
        end

        it 'increments user_sets view for the day if controller is story_items' do
          allow(request).to receive(:params) { { action: 'show', controller: 'story_items' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['user_sets']['show_item']).to eq 1

          user.update_daily_activity(request)
          expect(user.daily_activity['user_sets']['show_item']).to eq 2
        end

        it 'updates the requests for the record details' do
          allow(request).to receive(:params) { { action: 'show', controller: 'records' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['records']['show']).to eq 1
        end

        it 'updates the requests for multiple records' do
          allow(request).to receive(:params) { { action: 'multiple', controller: 'records' } }
          user.update_daily_activity(request)
          expect(user.daily_activity['records']['multiple']).to eq 1
        end

        it 'updates the requests for the source redirect' do
          allow(request).to receive(:params) { { action: 'source', controller: 'records' } }
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
          user.updated_at = Time.now.utc
        end

        it 'should return true when daily requests is greater than max requests' do
          user.attributes = { daily_requests: 100, max_requests: 99 }
          expect(user.over_limit?).to be_truthy
        end

        it 'should return false when daily requests is less than max requests' do
          user.attributes = { daily_requests: 100, max_requests: 110 }
          expect(user.over_limit?).to be_falsey
        end
      end

      context 'user wasnt updated today' do
        it 'should always return false' do
          user.attributes = { updated_at: Time.now.utc - 1.day, daily_requests: 100, max_requests: 99 }
          expect(user.over_limit?).to be_falsey
        end
      end
    end

    describe '#calculate_last_30_days_requests' do
      let!(:user) { create(:user) }
      let!(:user_activity) { create(:user_activity, user_id: user.id, total: 5, created_at: Time.now.utc) }

      it 'adds up the totals of the last 30 days' do
        create(:user_activity, user_id: user.id, total: 2, created_at: Time.now.utc - 5.days)
        expect(user.calculate_last_30_days_requests).to eq 7
      end

      it 'ignores requests older than 30 days' do
        create(:user_activity, user_id: user.id, total: 2, created_at: Time.now.utc - 31.days)
        expect(user.calculate_last_30_days_requests).to eq 5
      end

      it 'stores the requests in monthly_requests field' do
        user.calculate_last_30_days_requests
        expect(user.monthly_requests).to eq 5
      end
    end

    describe '#requests_per_day' do
      let!(:user) { create(:user) }

      before do
        create(:user_activity, user_id: user.id, total: 5, created_at: Time.now.utc - 1.day)
        create(:user_activity, user_id: user.id, total: 2, created_at: Time.now.utc)
      end

      it 'returns an array with the total requests per day' do
        expect(user.requests_per_day(2)).to eq [5, 2]
      end

      it 'returns 0 for days when there isnt any activity' do
        create(:user_activity, user_id: user.id, total: 1, created_at: Time.now.utc - 3.days)
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

    describe '#find_by_auth_token' do
      it 'searches for a user by its api key' do
        expect(User).to receive(:where).with(authentication_token: '1234').and_return([double(:record)])
        User.find_by_auth_token('1234')
      end

      it 'returns nil when user not found' do
        allow(User).to receive(:where).and_return([])
        expect(User.find_by_auth_token('1234')).to be_nil
      end
    end

    describe '#custom_find' do
      let(:user) { create(:user) }

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

    describe '#authentication_token' do
      let!(:user)    { create(:user, authentication_token: 'token') }
      let(:user_two) { build(:user, authentication_token: 'token')  }
      it 'enforces uniqueness on the authentication_token' do
        user_two.valid?
        expect(user_two.errors['authentication_token']).to include 'is already taken'
      end
    end
  end
end
