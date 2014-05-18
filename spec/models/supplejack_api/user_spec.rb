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
  
    before(:each) do
      Schema.stub(:default_role) { double(:role, name: :developer) }
    end
  
    describe '#role' do
      it 'should set the default value of the role from the Schema' do
        user.role.should eq 'developer'
      end
    end
    
    it 'should generate a authentication_token after creating a user' do    
      user.save
      user.reload
      user.authentication_token.should_not be_nil
    end

    describe '#name' do
      it "returns the user's name" do
        User.new(name: 'John').name.should eq 'John'
      end
  
      it 'returns the username when the name is empty' do
        User.new(username: 'ben').name.should eq 'ben'
      end
    end

    describe '#updated_today?' do
      it 'should return true if the user was last updated today' do
        user.updated_at = Time.now.beginning_of_day + 10.seconds
        user.updated_today?.should be_true
      end
      
      it 'should return false when the user was last updated yesterday' do
        user.updated_at = Time.now - 1.day
        user.updated_today?.should be_false
      end
    end

    describe '#check_daily_requests' do
      it "should reset daily requests if it wasn't updated today" do
        user.attributes = { updated_at: Time.now-1.day, daily_requests: 100 }
        user.check_daily_requests
        user.daily_requests.should eq 1
      end
      
      it 'should increment daily requests if it was updated today' do
        user.attributes = { updated_at: Time.now, daily_requests: 100 }
        user.check_daily_requests
        user.daily_requests.should eq 101
      end
      

      context 'api limit notifications' do
        pending 'Fix RequestLimitMailer issues'
        # before(:each) do
        #   @email = double
        #   RequestLimitMailer.stub(:at90percent) { @email }
        # end
  
        # it 'should send an email if the user is at 90% daily requests' do
        #   @email.should_receive(:deliver)
        #   user.attributes = { daily_requests: 89, updated_at: Time.now, max_requests: 100 }
        #   RequestLimitMailer.should_receive(:at90percent).with(user) { @email }
        #   user.check_daily_requests
        # end
  
        # it 'should not send an email if the user has past 90%' do
        #   user.attributes = { daily_requests: 90, updated_at: Time.now, max_requests: 100 }
        #   RequestLimitMailer.should_not_receive(:at90percent).with(user) { @email }
        #   user.check_daily_requests
        # end
  
        # it 'should send an email if the user has reached 100%' do
        #   @email.should_receive(:deliver)
        #   user.attributes = { daily_requests: 99, updated_at: Time.now, max_requests: 100 }
        #   RequestLimitMailer.should_receive(:at100percent).with(user) { @email }
        #   user.check_daily_requests
        # end
  
        # it 'should not send an email when the user has past 100%' do
        #   user.attributes = { daily_requests: 100, updated_at: Time.now, max_requests: 100 }
        #   RequestLimitMailer.should_not_receive(:at100percent).with(user) { @email }
        #   user.check_daily_requests
        # end
      end
    end

    describe '#increment_daily_requests' do
      it 'should increment daily_requests by 1' do
        user.attributes = { updated_at: Time.now, daily_requests: 100 }
        user.increment_daily_requests
        user.daily_requests.should eq 101
      end
      
      it 'increments daily requests when is nil' do
        user.attributes = { updated_at: Time.now, daily_requests: nil }
        user.increment_daily_requests
        user.daily_requests.should eq 1
      end
    end

    describe '#update_daily_activity' do
      let(:request) { double(:request, params: { action: ', controller: ' }).as_null_object }
  
      it 'sets the daily_activity_stored flag to false' do
        request.stub(:params) { { action: 'index', controller: 'records' } }
        user.update_daily_activity(request)
        user.daily_activity_stored.should be_false
      end
  
      context 'records and search requests' do
        it 'updates the search requests' do
          request.stub(:params) { { action: 'index', controller: 'records' } }
          user.update_daily_activity(request)
          user.daily_activity['search']['records'].should eq 1
        end
  
        it 'increases the amount of requests for the day' do
          request.stub(:params) { {action: 'index', controller: 'records'} }
          user.update_daily_activity(request)
          user.daily_activity['search']['records'].should eq 1
  
          user.update_daily_activity(request)
          user.daily_activity['search']['records'].should eq 2
        end
  
        it 'updates the requests for the record details' do
          request.stub(:params) { {action: 'show', controller: 'records'} }
          user.update_daily_activity(request)
          user.daily_activity['records']['show'].should eq 1
        end
  
        it 'updates the requests for multiple records' do
          request.stub(:params) { {action: 'multiple', controller: 'records'} }
          user.update_daily_activity(request)
          user.daily_activity['records']['multiple'].should eq 1
        end
  
        it 'updates the requests for the source redirect' do
          request.stub(:params) { {action: 'source', controller: 'records'} }
          user.update_daily_activity(request)
          user.daily_activity['records']['source'].should eq 1
        end
  
        it 'updates the requests for search through a custom search' do
          request.stub(:params) { {action: 'records', controller: 'custom_searches'} }
          user.update_daily_activity(request)
          user.daily_activity['search']['custom_search'].should eq 1
        end
      end
    end

    describe '#reset_daily_activity' do
      it 'nullifies the daily_activity' do
        user.reset_daily_activity
        user.daily_activity.should be_nil
      end
  
      it 'sets the daily_activity_stored flag to true' do
        user.daily_activity_stored = false
        user.reset_daily_activity
        user.daily_activity_stored.should be_true
      end
  
      it 'resets the daily requests count' do
        user.daily_requests = 100
        user.reset_daily_activity
        user.daily_requests.should eq 0
      end
    end

    describe '#over_limit?' do
      context 'user was updated today' do
        before(:each) do
          user.updated_at = Time.now
        end
        
        it 'should return true when daily requests is greater than max requests' do
          user.attributes = {daily_requests: 100, max_requests: 99}
          user.over_limit?.should be_true
        end
        
        it 'should return false when daily requests is less than max requests' do
          user.attributes = {daily_requests: 100, max_requests: 110}
          user.over_limit?.should be_false
        end
      end
      
      context "user wasn't updated today" do
        it 'should always return false' do
          user.attributes = {updated_at: Time.now-1.day, daily_requests: 100, max_requests: 99}
          user.over_limit?.should be_false
        end
      end
    end
  
    describe '#calculate_last_30_days_requests' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:user_activity) { FactoryGirl.create(:user_activity, user_id: user.id, total: 5, created_at: Time.now) }
  
      it 'adds up the totals of the last 30 days' do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now - 5.days)
        user.calculate_last_30_days_requests.should eq 7
      end
  
      it 'ignores requests older than 30 days' do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now - 31.days)
        user.calculate_last_30_days_requests.should eq 5
      end
  
      it 'stores the requests in monthly_requests field' do
        user.calculate_last_30_days_requests
        user.monthly_requests.should eq 5
      end
    end
  
    describe '#requests_per_day', pending: 'Not sure why this fails - should fix' do
      let!(:user) { FactoryGirl.create(:user) }
  
      before do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 5, created_at: Time.now - 1.day)
        FactoryGirl.create(:user_activity, user_id: user.id, total: 2, created_at: Time.now)
      end
  
      it 'returns an array with the total requests per day' do
        user.requests_per_day(2).should eq [5, 2]
      end
  
      it "returns 0 for days when there isn't any activity" do
        FactoryGirl.create(:user_activity, user_id: user.id, total: 1, created_at: Time.now - 3.day)
        user.requests_per_day(4).should eq [1, 0, 5, 2]
      end
    end
  
    describe '#name_or_user' do
      it 'should return the name' do
        user.name = 'Federico'
        user.name_or_user.should eq('Federico')
      end
  
      it 'should return the username' do
        user.name = ''
        user.username = 'fedegl'
        user.name_or_user.should eq('fedegl')
      end
    
      it 'should return the first part of the email address from name if email' do
        user.name = 'chris.mcdowall@dia.govt.nz'
        user.name_or_user.should eq('chris.mcdowall')
      end
    
      it 'should return the first part of the email address from username if email' do
        user.name = ''
        user.username = 'chris.mcdowall@dia.govt.nz'
        user.name_or_user.should eq('chris.mcdowall')
      end    
    end

    describe '#find_by_api_key' do
      it 'searches for a user by its api key' do
        User.should_receive(:where).with(authentication_token: '1234').and_return([double(:record)])
        User.find_by_api_key('1234')
      end
      
      it 'returns nil when user not found' do
        User.stub(:where).and_return([])
        User.find_by_api_key('1234').should be_nil
      end
    end
    
    describe '#custom_find' do
      let(:user) { FactoryGirl.create(:user) }
  
      it 'finds the user by the api_key' do
        User.custom_find(user.api_key).should eq user
      end
  
      it 'should raise a error when a record is not found' do
        expect { User.custom_find('sfsdfsdf') }.to raise_error(Mongoid::Errors::DocumentNotFound)
      end
  
      it 'finds the user by the id' do
        User.custom_find(user.id).should eq user
      end
    end

  end
end
