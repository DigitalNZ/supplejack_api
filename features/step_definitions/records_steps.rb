Given /^a record$/ do
  @record = FactoryGirl.create(:record)
end

When(/^I visit index page for the record$/) do
  visit(records_url(@record.record_id, format: :json, api_key: '12345'))
end