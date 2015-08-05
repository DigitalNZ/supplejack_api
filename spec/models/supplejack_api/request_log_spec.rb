# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe RequestLog do
  	let(:record) { FactoryGirl.build(:record, record_id: 123) }
  	let(:records) { [FactoryGirl.build(:record, record_id: 1234),
  									 FactoryGirl.build(:record, record_id: 12345),
  									 FactoryGirl.build(:record, record_id: 123456)
  									 ] }

  	describe '#create_search' do
      before(:each) do
  			@search = Search.new
  			@search.stub(:results) { records }
      end

  		it 'should create a RequestLog for search' do
  			@search.should_receive(:results)
  			SupplejackApi::RequestLog.should_receive(:create).with({:request_type=>"search", :log_values=>[1234, 12345, 123456]})
  			SupplejackApi::RequestLog.create_search(@search, "record_id")
  		end
  	end

  	describe '#create_find' do
  		it 'should create a RequestLog get' do
  			SupplejackApi::RequestLog.should_receive(:create).with({:request_type=>"get", :log_values=>[123]})
  			SupplejackApi::RequestLog.create_find(record, "record_id")
  		end
  	end	

  	describe '#create_user_set' do
  		let(:user_set) { FactoryGirl.build(:user_set)}

  		it 'should create a RequestLog get' do
  			user_set.stub(:set_items) { records }
  			SupplejackApi::Record.stub(:custom_find) { record }
  			SupplejackApi::RequestLog.should_receive(:create).with({:request_type=>"user_set", :log_values=>[123, 123, 123]})
  			SupplejackApi::RequestLog.create_user_set(user_set, "record_id")
  		end
  	end	

  end
end