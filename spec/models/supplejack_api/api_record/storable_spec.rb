require 'spec_helper'

module SupplejackApi
  describe ApiRecord::Storable do
    let(:record) { FactoryGirl.create(:record, record_id: 1234, internal_identifier: "nlnz:1234") }
    let(:source) { record.sources.create }
    
    context 'validations' do
      it 'should not be valid without a internal identifier' do
        record.internal_identifier = nil
        record.should_not be_valid
      end
    end
    
  end
end
