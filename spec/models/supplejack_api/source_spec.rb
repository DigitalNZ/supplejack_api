# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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