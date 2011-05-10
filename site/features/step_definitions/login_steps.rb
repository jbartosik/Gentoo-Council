Given /^example user$/ do
  user = User.new :name => "Example", :email_address => "example@example.com",
                  :password => "Example"
  user.save!
end

When /^I login as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  When "I fill in \"login\" with \"#{email}\""
  When "I fill in \"password\" with \"#{password}\""
  When 'I press "Login"'
end

When /^I login as example user$/ do
    When 'I login as "example@example.com" with password "Example"'
end
