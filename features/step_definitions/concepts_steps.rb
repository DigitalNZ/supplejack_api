# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given(/^these concepts:$/) do |table|
  table.hashes.each do |hash|
    hash["name"] = hash["name"].split(',')
  	concept = FactoryBot.create(:concept)
    fragment = FactoryBot.build(:concept_fragment, hash)
    concept.fragments << fragment
    concept.save
    concept.index
  end
end

When(/^I visit index page for the concepts$/) do
  @request_url = concepts_url({ format: 'json', api_key: @user.api_key })
  visit(@request_url)
end

Given(/^I have a concept$/) do
  @concept = FactoryBot.create(:concept)
  @concept.source_authorities << FactoryBot.create(:source_authority)
  @concept.save
end

When(/^I get a concept$/) do
  request_url = concept_url(@concept.concept_id, format: 'json', api_key: @user.api_key)
  visit(request_url)
end

When(/^I get a concept with inline context$/) do
  request_url = concept_url(@concept.concept_id, format: 'json', api_key: @user.api_key, inline_context: true)
  visit(request_url)
end

When(/^I get a concept with "(.*?)" field$/) do |field|
  visit(concept_url(@concept.concept_id, format: 'json', api_key: @user.api_key, fields: field))
end

When(/^I filter a concept by source_authortiy/) do
  request_url = concepts_url({ format: 'json', api_key: @user.api_key, and: { source_authority: @concept.source_authorities.first.internal_identifier } })
  visit request_url
end
