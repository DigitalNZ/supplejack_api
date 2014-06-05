# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Given /^a record with the id "(.*?)"$/ do |record_id|
  @record = FactoryGirl.create(:record_with_fragment, record_id: record_id)
end

When /^I post a request to (?:create|update) a fragment with the JSON:$/ do |json|
  post "/harvester/records/#{@record.id}/fragments.json", JSON.parse(json)
end

Then /^the (?:concept|record) should have a fragment with the source id "(.*?)" and the attributes:$/ do |source_id, table|
  @object = instance_variable_get("@record") || instance_variable_get("@concept")
  @object.reload
  @fragment = @object.find_fragment(source_id)
  table.hashes.each do |attribute_hash|
    attribute_hash.each do |name, expected_value|
      value = @fragment.send(name)
      value = value.first if value.is_a?(Array)
      value.to_s.should eq expected_value
    end
  end
end

Given /^a fragment with source id of "(.*?)" and the attributes:$/ do |source_id, table|
  @object = instance_variable_get("@record") || instance_variable_get("@concept")
  @object.primary_fragment.update_from_harvest({source_id: source_id}.merge(table.hashes.first))
  @object.save!
end

Then /^the (?:record|concept) should have (\d+) fragments?$/ do |count|
  @object = instance_variable_get("@record") || instance_variable_get("@concept")
  @object.fragments.count.should eq count.to_i
end

