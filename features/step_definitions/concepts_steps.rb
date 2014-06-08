# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given(/^these concepts:$/) do |table|
  table.hashes.each do |hash|
  	concept = FactoryGirl.create(:concept, internal_identifier: "c:#{rand(1000..10000)}")
    fragment = FactoryGirl.build(:concept_fragment, hash)
    concept.fragments << fragment
    concept.save
    concept.index
  end
end

When(/^I visit index page for the concepts$/) do
  @request_url = concepts_url({ format: 'json', api_key: @user.api_key })
  visit(@request_url)
end

Given(/^a concept$/) do
  @concept = FactoryGirl.create(:concept)
  @concept.fragments << FactoryGirl.build(:concept_fragment)
  @concept.save
end

When(/^I get a concept$/) do
  request_url = concept_url(@concept.concept_id, format: 'json', api_key: @user.api_key, fields: 'all')
  visit(request_url)
end

When(/^I get a concept with "(.*?)" field$/) do |field|
  visit(concept_url(@concept.concept_id, format: 'json', api_key: @user.api_key, fields: field))
end