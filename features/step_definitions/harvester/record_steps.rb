

When /^I post a request to (?:create|update) a record with the JSON:$/ do |json|
  post "/harvester/records.json", JSON.parse(json)
end

Then /^there should be a new record with the identifier "(.*?)"$/ do |identifier|
  @record = SupplejackApi::Record.find_by(internal_identifier: identifier)
end

Given /^a record with the identifier "(.*?)"$/ do |identifier|
  @record = create(:record_with_fragment, internal_identifier: identifier)
end

When /^I post a request to flush records with a source_id of "(.*?)" and a job_id of "(.*?)"$/ do |source_id, job_id|
  post "/harvester/records/flush.json", {source_id: source_id, job_id: job_id}
end

Then /^the record with the identifier "(.*?)" should have status "(.*?)"$/ do |identifier, status|
  @record = SupplejackApi::Record.where(internal_identifier: identifier).first
  @record.status.should eq status
end

When /^I send a put request to mark the record as deleted with the identifier "(.*?)"$/ do |identifier|
  put "/harvester/records/delete.json", id: identifier
end

When /^I send a request to update the status of the record to "(.*?)"$/ do |status|
  put("/harvester/records/#{@record.record_id}.json", { record: { status: status }})
end

Then /^the status of the record should be "(.*?)"$/ do |status|
  @record.reload.status.should eq status
end

Then(/^the record should have attributes:$/) do |table|
  @record.reload
  table.hashes.each do |attribute_hash|
    attribute_hash.each do |name, expected_value|
      value = @record.send(name)
      value = value.first if value.is_a?(Array)
      value.to_s.should eq expected_value
    end
  end
end

Given(/^show me the record$/) do
  puts "Record: #{@record.reload.inspect}"
  puts "Fragments: #{@record.fragments.inspect}"
end
