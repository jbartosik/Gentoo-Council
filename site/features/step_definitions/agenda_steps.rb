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
