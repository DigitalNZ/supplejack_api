# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given(/^these records:$/) do |table|
  table.hashes.each do |hash|
  	record = FactoryGirl.create(:record, internal_identifier: "abc:#{rand(1000..10000)}")
    fragment = FactoryGirl.build(:fragment, hash)
    record.fragments << fragment
    record.save
  end
end

Given /^a record$/ do
  @record = FactoryGirl.create(:record)
  @record.fragments << FactoryGirl.build(:fragment)
  @record.save
end

When(/^I get a record$/) do
  visit(record_url(@record, format: 'json', api_key: @user.api_key, fields: 'all'))
end

When(/^I visit index page for the record$/) do
  @request_url = records_url({ format: 'json', api_key: @user.api_key })
  visit(@request_url)
end