

require 'spec_helper'

module SupplejackApi
  describe UserActivity do
    let(:activity) { SupplejackApi::UserActivity.new }
    
    describe '#calculate_total_for' do
      it 'generates the total for the grouped activities' do
        activity.user_sets = {create: 1, update: 2, destroy: 3, index: 4, show: 5}
        activity.calculate_total_for(:user_sets)
        expect(activity.user_sets['total']).to eq 15
      end
  
      it 'handles activities with null values' do
        activity.search = {records: nil, custom_search: 3}
        activity.calculate_total_for(:search)
        expect(activity.search['total']).to eq 3
      end
  
      it 'handles where the whole hash is nil' do
        activity.search = nil
        activity.calculate_total_for(:search)
        expect(activity.search['total']).to eq 0
      end
    end
  
    describe '#calculate_total' do
      it 'calculates the overall total' do
        activity.user_sets =        {'total' => 1}
        activity.search =           {'total' => 2}
        activity.records =          {'total' => 3}
        activity.custom_searches =  {'total' => 5}
        activity.calculate_total
        expect(activity.total).to eq 11
      end
  
      it 'handles nil fields' do
        activity.user_sets = nil
        activity.calculate_total
        expect(activity.total).to eq 0
      end
    end
  
    describe '#build_from_user' do
      let(:activity) { {'user_sets' =>        {'total' => 1}, 
                        'search' =>           {'custom_search' => 2},
                        'records' =>          {'show' => 1, 'multiple' => 2}, 
                        'custom_searches' =>  {'index' => 1, 'show' => 2}
                      } }
  
      it 'buils a user_activity with user_sets stats' do
        user_activity = SupplejackApi::UserActivity.build_from_user(activity)
        expect(user_activity.user_sets).to eq({'total' => 1})
      end
  
      it 'buils a user_activity with search stats' do
        user_activity = SupplejackApi::UserActivity.build_from_user(activity)
        expect(user_activity.search).to eq({'custom_search' => 2, 'total' => 2})
      end
  
      it 'buils a user_activity with records stats' do
        user_activity = SupplejackApi::UserActivity.build_from_user(activity)
        expect(user_activity.records).to eq({'show' => 1, 'multiple' => 2, 'total' => 3})
      end
  
      it 'buils a user_activity with custom_searches stats' do
        user_activity = SupplejackApi::UserActivity.build_from_user(activity)
        expect(user_activity.custom_searches).to eq({'index' => 1, 'show' => 2, 'total' => 3})
      end
  
      it 'calculates the total of requests' do
        user_activity = SupplejackApi::UserActivity.build_from_user(activity)
        expect(user_activity.total).to eq 9
      end
  
      it 'returns nil when there is no activity for a group' do
        expect(SupplejackApi::UserActivity.build_from_user(nil).records).to be_nil
      end
    end
  end
end
