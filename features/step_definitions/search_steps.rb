

def search_options(text, facet, format, filters)
	options = { format: 'json', api_key: '12345', text: text }
  options[:facets] = facet.to_s if facet.present?
  options[:format] = @format.to_s if @format.present?
  options.merge!(filters)
  options
end

def execute_concept_search(text, facet, format, filters={})
  options = search_options(text, facet, format, filters)
  @request_url = concepts_url(options)
  visit(@request_url)
end

def execute_record_search(text, facet, format, filters={})
  options = search_options(text, facet, format, filters={})
  @request_url = records_url(options)
  visit(@request_url)
end

# Record search
When /^I search record for "([^"]*)"(?: with facet "(.*)")?$/ do |search_text, facet|
  execute_record_search(search_text, facet, @format)
end

When /^I search record for a field "(.*)"$/ do |search_text|
  execute_record_search(search_text.gsub('\\', ''), nil, @format)
end

# Concept search
When /^I search concept for "([^"]*)"(?: with facet "(.*)")?$/ do |search_text, facet|
  execute_concept_search(search_text, facet, @format)
end

When /^I search concept for a field "(.*)"$/ do |search_text|
  execute_concept_search(search_text.gsub('\\', ''), nil, @format)
end

When(/^I search concept for "(.*?)" within "(.*?)" field$/) do |search_text, query_fields|
  execute_concept_search(search_text, nil, @format, { query_fields: query_fields })
end

When(/^I search concept with sort by "(.*?)" in "(.*?)" order$/) do |field, order|
  execute_concept_search('', nil, @format, { fields: 'all', sort: field, direction: order })
end

When(/^I search concept for "(.*?)" with "(.*?)" fields$/) do |search_text, fields|
  execute_concept_search(search_text, nil, @format, { fields: 'all', fields: fields })
end
