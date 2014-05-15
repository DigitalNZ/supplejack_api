# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

When /^I create a partner with the JSON:$/ do |json|
  post partners_path, JSON.parse(json)
end

Then /^there should be a partner called "(.*?)"$/ do |name|
  SupplejackApi::Partner.where(name: name).count.should eq 1
end

Given /^these partners exist:$/ do |table|
  table.hashes.each do |partner|
    SupplejackApi::Partner.create(partner)
  end
end

Given /^a partners exists named "(.*?)"$/ do |name|
  @partner = SupplejackApi::Partner.create(name: name)
end

When /^I get the partner$/ do
  visit(partner_path(@partner.id))
end

When /^I list the partners$/ do
  visit(partners_path)
end

When /^I update the partner with:$/ do |json|
  put partner_path(@partner), JSON.parse(json)
end

Then /^the partner with id "(.*?)" should be called "(.*?)"$/ do |id, name|
  SupplejackApi::Partner.find(id).name.should eq name
end