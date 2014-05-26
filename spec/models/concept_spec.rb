# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe Concept do
    let(:concept) { create(:concept) }

    subject { concept }

    it { should be_timestamped_document }
    it { should be_stored_in :concepts }
    it { should be_timestamped_document.with(:created) }
    it { should be_timestamped_document.with(:updated) }
    
    it { should embed_many(:fragments) }

    describe '#active?' do
    	before { @record = build(:record) }

      it 'returns true when state is active' do
        @record.status = 'active'
        @record.active?.should be_true
      end
  
      it 'returns false when state is deleted' do
        @record.status = 'deleted'
        @record.active?.should be_false
      end
    end
  
    describe '#should_index?' do
      before { @record = build(:record) }
  
      it 'returns false when active? is false' do
        @record.stub(:active?) { false }
        @record.should_index?.should be_false
      end
  
      it 'returns true when active? is true' do
        @record.stub(:active?) { true }
        @record.should_index?.should be_true
      end
    end
  end
end
