# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack
require 'pry'
def last_json
  page.source
end

def last_xml
  page.source
end

Then /^the JSON at "([^"]*)" should be the requested url$/ do |path|
  last_json.should be_json_eql("\"#{@request_url}\"").at_path(path)
end

Then /^show me the JSON$/ do
  puts "The JSON is: " + JSON.pretty_generate(JSON.parse(last_json.to_s))
end

When /^I request a XML format$/ do
  @format = :xml
end

When(/^I visit "(.*?)"$/) do |url|
  visit(url)
end

Then(/^I should be on "(.*?)"$/) do |path|
  expect(current_path).to eq(path)
end

Then(/^I should see "(.*?)"$/) do |text|
  expect(page).to have_content(text)
end

Then(/^I should not see "(.*?)"$/) do |text|
  expect(page).to have_no_content(text)
end

Then(/^I should see "(.*?)" link$/) do |link|
  expect(find_link(link)).to_not be_nil
end

When(/^I click "(.*?)" link$/) do |link|
  begin
    click_link(link)
  rescue Capybara::Ambiguous => e
    first(:link, link).click
  end
end

Then (/^show me the page$/) do
  save_and_open_page
end

When(/^I click "(.*?)" button$/) do |button|
  begin
    click_button(button)
  rescue Capybara::Ambiguous => e
    first(:button, button).click    
  end
end