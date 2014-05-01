Given /^a record with the id "(.*?)"$/ do |record_id|
  @record = FactoryGirl.create(:record_with_fragment, record_id: record_id)
end

When /^I post a request to (?:create|update) a fragment with the JSON:$/ do |json|
  post "/harvester/records/#{@record.id}/fragments.json", JSON.parse(json)
end

Then /^the record should have a fragment with the source id "(.*?)" and the attributes:$/ do |source_id, table|
	@record.reload
	@fragment = @record.find_fragment(source_id)
	table.hashes.each do |attribute_hash|
		attribute_hash.each do |name, expected_value|
			value = @fragment.send(name)
			value = value.first if value.is_a?(Array)
			value.to_s.should eq expected_value
		end
	end
end

Given /^a fragment with source id of "(.*?)" and the attributes:$/ do |source_id, table|
	@record.primary_fragment.update_from_harvest({source_id: source_id}.merge(table.hashes.first))
  @record.save!
end

Then /^the record should have (\d+) fragments?$/ do |count|
  @record.fragments.count.should eq count.to_i
end

