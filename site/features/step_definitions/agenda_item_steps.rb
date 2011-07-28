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

When /^I fill in example agenda item data$/ do
  When "I fill in the following:", table(%{
    |agenda_item_title|examle|
    |agenda_item_discussion|http://example.com/mailinglist/example|
    |agenda_item_body|example|
  })
end

Given /^example agenda item$/ do
  AgendaItem.new(:title => 'example', :discussion => '', :body => 'example').save!
end

Given /^rejected agenda item$/ do
  AgendaItem.new(:title => 'Rejected item', :discussion => '', :body => 'example', :rejected => true).save!
end

When /^I follow first suggested agenda link$/ do
  firstItem = AgendaItem.first :conditions => {:agenda_id => nil, :rejected => false}
  When "I follow \"#{firstItem.title}\""
end

When /^I should see current agenda as the agenda$/ do
  When "I should see \"Agenda #{Agenda.current.id}\" within \".agenda-item-agenda\""
end

Given /^agenda item in current agenda$/ do
  Agenda.create!
  AgendaItem.create! :agenda => Agenda.last, :title => 'Item in current agenda'
end

Then /^I should see "([^"]*)" button inside content body$/ do |arg1|
  within('.content-body') do
    page.all(:xpath, "//input[@type='submit'][@value='#{arg1}']").should_not be_empty
  end
end

Then /^"([^"]*)" button should be inline$/ do |arg1|
  within('.one-button-form') do
    page.all(:xpath, "//input[@type='submit'][@value='#{arg1}']").should_not be_empty
  end
end

Given /^some agenda item with discussion times$/ do
  Factory(:agenda_item)
  Factory(:agenda_item, :discussion_time => 'From 2011.07.01 to 2011.07.05, 4 full days')
  Factory(:agenda_item, :discussion_time => 'manually set')
end

Then /^I should see discussion times when viewing agenda items$/ do
  AgendaItem.all.each do |item|
    When "I am on agenda item number #{item.id} show page"
    Then "I should see \"#{item.discussion_time}\""
  end
end
