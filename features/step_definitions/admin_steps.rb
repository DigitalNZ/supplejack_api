

Given(/^an admin user$/) do
  @user = create(:admin_user, authentication_token: '12345', daily_requests: 0, username: 'Admin User')
end

When(/^I enter my admin credentials$/) do
  fill_in('admin_user_email', with: @user.email)
  fill_in('admin_user_password', with: @user.password)
  click_button('Sign in')
end

Then(/^I should signed in successfully$/) do
  expect(page).to have_content I18n.t('devise.sessions.signed_in')
end

Then(/^I should signed out successfully$/) do
  expect(page).to have_content I18n.t('devise.sessions.signed_out')
end

When(/^I click the user's API key$/) do
  click_link(@user.authentication_token) 
end

Then(/^I should see "(.*?)" table$/) do |table|
  case table
  when table == 'users'
  	expect(page).to have_content 'Username'
  	expect(page).to have_content 'Name'
  	expect(page).to have_content 'API Key'
  	expect(page).to have_content 'Email'
  	expect(page).to have_content 'Role'
  	expect(page).to have_content 'API requests today'
  	expect(page).to have_content 'API requests last 30 days'
  	expect(page).to have_content 'Max Requests'
  when table == 'usage'
  	expect(page).to have_content 'Date'	
  	expect(page).to have_content 'User Sets'	
  	expect(page).to have_content 'Search'	
  	expect(page).to have_content 'Records'	
  	expect(page).to have_content 'Source Clicks'	
  	expect(page).to have_content 'Total'	
  end
end

Then(/^I should see user's details$/) do
  expect(page).to have_content @user.name
  expect(page).to have_content @user.username
  expect(page).to have_content @user.email
end

When(/^I click the user's Max Requests$/) do
 	click_link(@user.max_requests.to_s)
end

When(/^I enter "(.*?)" as Max Requests$/) do |max_requests|
  fill_in('user_max_requests', with: max_requests)
  click_button('Update User')
end

Then(/^I should should see the updated Max Requests$/) do
  expect(page).to have_content '900'
end
