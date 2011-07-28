#   Gentoo Council Web App - to help Gentoo Council do their job better
#   Copyright (C) 2011 Joachim Filip Bartosik
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Affero General Public License as
#   published by the Free Software Foundation, version 3 of the License
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Affero General Public License for more details.
#
#   You should have received a copy of the GNU Affero General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

