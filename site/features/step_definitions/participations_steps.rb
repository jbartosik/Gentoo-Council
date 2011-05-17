Given /^some council members$/ do
  (1..8).each do |n|
    u = User.new
    u.name = "Member no #{n}"
    u.email = "member-#{n}@example.com"
    u.irc_nick = "member-#{n}"
    u.password = "Example"
    u.council_member = true
    u.save!
  end
end

Given /^I am logged in as council member$/ do
  When 'I am on the login page'
  When 'I fill in "login" with "member-1@example.com"'
  When 'I fill in "password" with "Example"'
  When 'I press "Login"'
end

Then /^I should see all council members as participants$/ do
  User.council_member_is(true).each do |m|
    Then "I should see \"#{m.name}\" within \".collection.participations.participations-collection\""
  end
end
