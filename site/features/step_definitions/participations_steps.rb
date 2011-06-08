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

When /^application got voting results from IRC bot$/ do
  Participation.mark_participations({ 'Some item' =>
    { User.first.irc_nick => 'Some vote',
      User.last.irc_nick => 'Some other vote' } })
end

Then /^I should see some council members as participants$/ do
  Then "I should see \"#{User.first.name}\" within \".collection.participations.participations-collection\""
  Then "I should see \"#{User.last.name}\" within \".collection.participations.participations-collection\""
end
