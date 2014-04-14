def last_json
  page.source
end

def last_xml
  page.source
end

Given(/^these Records:$/) do |table|
  table.hashes.each do |hash|
  	record = FactoryGirl.build(:record, internal_identifier: "abc:#{rand(1000..10000)}")
  	fragment = record.fragments.build
  	[:address, :email, :age, :children, :nz_citizen].each do |field|
      if SupplejackApi::Fragment.fields[field.to_s].try(:type) == Array
        value = hash[field].try(:split, ', ')
      else
        value = hash[field]
      end
      fragment.send("#{field}=", value) if value.present?
    end

    record.save
  end
end

Given /^a record$/ do
  @record = FactoryGirl.create(:record)
end

When(/^I get a record$/) do
  visit(record_path(@record, format: 'json', api_key: @user.authentication_token, fields: 'all'))
end

When(/^I visit index page for the record$/) do
  visit(records_path(api_key: @user.authentication_token))
  p page.body
end