Given /^a regular user$/ do
  Factory(:user, :name => "User")
end

When /^I view profile of a regular user$/ do
  Given 'a regular user'
  When 'I am on the "User" show page'
end

Then /^I confirm$/ do
  page.driver.browser.switch_to.alert.accept
end

Then /^I should not see "([^"]*)" button$/ do |arg1|
  page.all(:xpath, "//input[@type='submit'][@value='#{arg1}']").should be_empty
end

Given /^someone appointed a proxy$/ do
  Factory(:user, :council_member => true, :name => 'Member-who-appointed')
  Factory(:proxy, :agenda => Agenda.current)
end

When /^I view old meeting for which I appointed a proxy$/ do
  a = Factory(:agenda, :state => 'old')
  Factory(:proxy, :council_member => User.council_member_is(true).first, :agenda => a)
  When "I am on #{a.id}th agenda page"
end

