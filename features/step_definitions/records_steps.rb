# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given(/^these records:$/) do |table|
  table.hashes.each do |hash|
    hash["email"] = hash["email"].split(',') if hash["email"]
    hash["children"] = hash["children"].split(',') if hash["children"]
    hash["contact"] = hash["contact"].split(',') if hash["contact"]
    record = FactoryGirl.create(:record, internal_identifier: "abc:#{rand(1000..10000)}", record_id: hash[:record_id])
    fragment = FactoryGirl.build(:record_fragment, hash.except('record_id'))
    record.fragments << fragment
    record.save
  end
end

Given /^a record$/ do
  @record = FactoryGirl.create(:record)
  @record.fragments << FactoryGirl.build(:record_fragment)
  @record.save
end

When(/^I get a record$/) do
  visit(record_url(@record, format: 'json', api_key: @user.api_key, fields: 'all'))
end

When(/^I visit index page for the record$/) do
  @request_url = records_url({ format: 'json', api_key: @user.api_key })
  visit(@request_url)
end