Given /^an ?(\w*) agenda$/ do |state|
  a = Agenda.new
  state = 'submissions_closed' if state == 'closed'
  a.state = state unless state.empty?
  a.save! if a.valid?
end

Then /^I should see current date as meeting time$/ do
  Then "I should see \"#{Time.now.strftime("%d %b %Y")}\" as meeting time"
end

When /^I follow link to first agenda$/ do
  link_text = page.find(:xpath, "//a[contains(@class, 'agenda-link')]").text
  When "I follow \"#{link_text}\""
end

When /^I follow link to current agenda$/ do
  a = Agenda.current
  When "I follow \"Agenda #{a.id}\""
end

When /^I am logged in as a council member$/ do
  Given 'example user'
  user = User.last
  user.council_member = true
  user.save
  When 'I am on the login page'
  When 'I login as example user'
end

When /^I (\w+) current agenda$/ do |action|
    When "I follow \"#{action.camelize} this agenda\""
    When "I press \"#{action.camelize}\""
end
