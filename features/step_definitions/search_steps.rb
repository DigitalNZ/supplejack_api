# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

def execute_search(text, facet, format, filters={})
  options = { format: 'json', api_key: '12345', text: text }
  options[:facets] = "#{facet.to_s}" if facet.present?
  options[:format] = @format.to_s if @format.present?
  options.merge!(filters)
  @request_url = records_url(options)
  visit(@request_url)
end

When /^I search for "([^"]*)"(?: with facet "(.*)")?$/ do |search_text, facet|
  execute_search(search_text, facet, @format)
end

When /^I search for a field "(.*)"$/ do |search_text|
  execute_search(search_text.gsub('\\', ''), nil, @format)
end

When /^I search for "(.*?)" with suggest$/ do |search_text|
  execute_search(search_text, nil, @format, {suggest: true})
end