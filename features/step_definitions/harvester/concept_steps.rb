

When /^I post a request to (?:create|update) a concept with the JSON:$/ do |json|
  post "/harvester/concepts.json", JSON.parse(json)
end

Then(/^the concept with the identifier "(.*?)" should have attributes:$/) do |identifier, table|
  @concept = SupplejackApi::Concept.where(internal_identifier: identifier).first
  table.hashes.each do |attribute_hash|
    attribute_hash.each do |name, expected_value|
      value = @concept.send(name)
      value = value.first if value.is_a?(Array)
      value.to_s.should eq expected_value
    end
  end
end

Given /^a concept with the identifier "(.*?)"$/ do |identifier|
  @concept = create(:concept_with_fragment, internal_identifier: identifier)
end

