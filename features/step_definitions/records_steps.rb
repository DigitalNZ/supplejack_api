

Given(/^these records:$/) do |table|
  table.hashes.each do |hash|
    hash["email"] = hash["email"].split(',') if hash["email"]
    hash["children"] = hash["children"].split(',') if hash["children"]
    hash["contact"] = hash["contact"].split(',') if hash["contact"]
    record = FactoryBot.create(:record, internal_identifier: "abc:#{rand(1000..10000)}", record_id: hash[:record_id])
    fragment = FactoryBot.build(:record_fragment, hash.except('record_id'))
    record.fragments << fragment
    record.save
  end
end

Given /^a record$/ do
  @record = FactoryBot.create(:record)
  @record.fragments << FactoryBot.build(:record_fragment)
  @record.save
end

When(/^I get a record$/) do
  visit(record_url(@record, format: 'json', api_key: @user.api_key, fields: 'all'))
end

When(/^I visit index page for the record$/) do
  @request_url = records_url({ format: 'json', api_key: @user.api_key })
  visit(@request_url)
end
