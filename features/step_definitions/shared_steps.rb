Then /^the JSON at "([^"]*)" should be the requested url$/ do |path|
  last_json.should be_json_eql("\"#{@request_url}\"").at_path(path)
end

Then /^show me the JSON$/ do
  puts "The JSON is: " + JSON.pretty_generate(JSON.parse(last_json.to_s))
end

When /^I request a XML format$/ do
  @format = :xml
end