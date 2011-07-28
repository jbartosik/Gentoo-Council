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
