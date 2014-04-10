require 'spec_helper'

module SupplejackApi
  describe Source do
  
  	describe '.suppressed' do
  		let!(:active_source) { FactoryGirl.create(:source, status: 'active') }
  		let!(:suppressed_source) { FactoryGirl.create(:source, status: 'suppressed') }
  
  		it 'should return all the suppressed sources' do
  		  Source.suppressed.to_a.should eq [suppressed_source]
  		end
  	end
  end
end