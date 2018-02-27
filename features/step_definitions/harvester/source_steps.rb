

When /^I create a source with the JSON:$/ do |json|
  post partner_sources_path(@partner.id), JSON.parse(json)
  @partner.reload
end

Then /^there should be a source called "(.*?)"$/ do |name|
  @partner.reload
  @partner.sources.last.name.should eq name
end

Then /^there should be a source_id of "(.*?)"$/ do |source_id|
  @partner.sources.last.source_id.should eq source_id
end

Given /^I have the following sources:$/ do |table|
  table.hashes.each do |hash|
    @partner.sources.create(hash)
  end
  @partner.reload
end

When /^I get the first source$/ do
  last_source = @partner.sources.first
  visit(source_path(last_source, partner_id: @partner.id))
end

When /^I list all sources$/ do
  visit(sources_path)
end

Given /^a source exists named "(.*?)"$/ do |name|
  @partner.sources.create(name: name)
end

When /^I update the source with:$/ do |json|
  last_source = @partner.sources.first
  put source_path(id: last_source), JSON.parse(json)
end

Then /^there should be souce id with "(.*?)"$/ do |source_id|
  @partner.reload
  @partner.sources.last.source_id.should eq source_id
end

Then /^the source with id "(.*?)" should be called "(.*?)"$/ do |id, name|
  @partner.sources.find(id).name.should eq name
end
