# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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
