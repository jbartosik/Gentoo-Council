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

Given /^example user$/ do
  user = User.new :name => "Example", :email => "example@example.com",
                  :password => "Example", :irc_nick => "example"
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

When /^I close browser$/ do
  Capybara.current_session.driver.is_a?(Capybara::Driver::Selenium).should be_true
  browser = Capybara.current_session.driver.browser
  browser.manage.all_cookies.each do |cookie|
    if cookie[:expires].nil? || cookie[:expires] < Time.now
      browser.manage.delete_cookie(cookie[:name])
    end
  end
end
