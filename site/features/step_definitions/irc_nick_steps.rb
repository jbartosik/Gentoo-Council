When /^I fill in example user registration data$/ do
  When "I fill in the following:", table(%{
    |user_name|examle|
    |user_email|example@example.com|
    |user_irc_nick|example|
    |user_password|Example|
    |user_password_confirmation|Example|
  })
end

When /^I signup as example user without IRC nick$/ do
  When 'I fill in example user registration data'
  When 'I fill in "user_irc_nick" with ""'
  When 'I press "Signup"'
end

When /^I signup as example user with IRC nick$/ do
  When 'I fill in example user registration data'
  When 'I press "Signup"'
end

Given /^I am logged in as example user$/ do
    Given 'example user'
    When 'I am on the login page'
    When 'I login as example user'
end
