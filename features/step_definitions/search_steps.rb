def execute_search(text, facet, format, filters={})
  options = { format: 'json', api_key: '12345', text: text }
  options[:facets] = "#{facet.to_s}" if facet.present?
  options[:format] = @format.to_s if @format.present?
  options.merge!(filters)
  @request_url = records_url(options)
  p @request_url
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