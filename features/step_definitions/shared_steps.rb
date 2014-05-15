# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

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