

Given /^a user with an? API Key$/ do
  @user = create(:user, authentication_token: '12345', daily_requests: 0, username: 'Test User')
end

When /^the user requests an API resource with (?:his|her) API key$/ do  
  visit(user_path(@user, format: :json, api_key: '12345'))
end

Then /^the request is successful$/ do
  page.status_code.should eq 200
end

When /^the user requests an API resource with an invalid API key$/ do
  visit(user_path(@user, format: :json, api_key: 'invalidkey'))
end

Then /^(?:it|he|she) should see the error: "(.*)"$/ do |error_message|
  page.should have_content error_message
end

Given /^the user has reached its daily requests limit$/ do
  @user.update_attributes(daily_requests: 101, max_requests: 100)
  @user.reload
end

Then /^(?:it|he|she) should have incremented its daily requests by one$/ do
  @user.reload
  @user.daily_requests.should eq 1
end
