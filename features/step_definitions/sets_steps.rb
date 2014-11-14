# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given(/^I have a set with the following values:$/) do |table|
  @user_set = @user.user_sets.build
  table.hashes.each do |hash|
    @user_set.send("#{hash['field']}=", hash['value'])
  end
  @user_set.save
end

When(/^I request the set information$/) do
  visit user_set_path(@user_set.id, api_key: @user.authentication_token)
end

Given(/^the set has the following items:$/) do |table|
  table.hashes.each do |hash|
    @user_set.set_items.build(hash)
  end
  @user_set.save
end

When(/^I post a request to create a set with the JSON:$/) do |json|
  post user_sets_path(api_key: @user.authentication_token), JSON.parse(json)
end

Then(/^I should have (\d+) sets$/) do |sets_count|
  @user.reload
  @user.user_sets.count.should eq(sets_count.to_i)
end

Given(/^I have a set with name "(.*?)"$/) do |name|
  @user_set = @user.user_sets.create(name: name)
end

When(/^I post a request to add a set item with the JSON:$/) do |json|
  post user_set_set_items_path(@user_set.id, api_key: @user.authentication_token, format: "json"), JSON.parse(json)
end

Then(/^there should be (\d+) items in the set$/) do |count|
  @user_set.reload
  @user_set.set_items.count.should eq count.to_i
end

Then(/^the item with record_id of (\d+) should have a "(.*?)" of (\d+)$/) do |record_id, field, value|
  @user_set.reload
  @set_item = @user_set.set_items.where(record_id: record_id.to_i).first
  @set_item.send(field).should eq value.to_i
end

When(/^I issue a delete request to remove set item with record_id (\d+)$/) do |record_id|
  delete user_set_set_item_path(@user_set.id, record_id.to_i, api_key: @user.authentication_token, format: "json")
end

Then(/^I should have a set with the values:$/) do |table|
  @user_set = SupplejackApi::UserSet.where(user_id: @user.id).first
  table.hashes.each do |attributes|
    value = ["count"].include?(attributes["field"]) ? attributes["value"].to_i : attributes["value"]
    @user_set.send(attributes["field"]).should eq value
  end
end

When(/^I do a put request to update the set with the JSON:$/) do |json|
  put user_set_path(@user_set, api_key: @user.authentication_token), JSON.parse(json)
end

Then(/^the set should have (\d+) set items with the values:$/) do |items_count, table|
  @user_set.reload
  @user_set.set_items.count.should eq items_count.to_i
  table.hashes.each do |item_attrs|
    set_item = @user_set.set_items.where(record_id: item_attrs["record_id"].to_i).first
    set_item.position.should eq item_attrs["position"].to_i
  end
end

Given(/^I have a set with name "(.*?)" with the set items:$/) do |name, table|
  @user_set = @user.user_sets.build(name: name)
  if table
    table.hashes.each do |item_attrs|
      @user_set.set_items.build(record_id: item_attrs["record_id"].to_i, position: item_attrs["position"])
    end
  end
  @user_set.save
end

When(/^I request my sets$/) do
  visit user_sets_path(api_key: @user.authentication_token)
end

When(/^I issue a delete request for the set$/) do
  delete user_set_path(@user_set.id, api_key: @user.authentication_token, format: "json")
end

Then(/^the set should have (\d+) tags the values:$/) do |tags_count, table|
  @user_set.reload
  expect(@user_set.tags.count).to eq 2
  table.hashes.each do |hash|
    expect(@user_set.tags).to include hash['tags']
  end
end