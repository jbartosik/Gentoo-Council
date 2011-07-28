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

Given /^some agendas$/ do
  for i in 1..11
    Factory(:agenda, :state => 'old', :meeting_time => i.months.ago)
  end
  Factory(:agenda)
end

Given /^some council members who attended properly$/ do
  users = users_factory([:council]*3)
  for a in Agenda.all
    for u in users
      Factory(:participation, :participant => u, :agenda => a)
    end
  end
end

Given /^some council members who skipped last meeting$/ do
  users = users_factory([:council]*3)
  for a in Agenda.all - [Agenda.last]
    for u in users
      Factory(:participation, :participant => u, :agenda => a)
    end
  end
end

Given /^some slackers$/ do
  users = users_factory([:council]*3)
  i = 0
  for a in Agenda.all
    next if i < 2
    for u in users
      Factory(:participation, :participant => u, :agenda => a)
    end
  end
end

Given /^some slackers who skipped a meeting$/ do
  users = users_factory([:council]*3)
  i = 0
  for a in Agenda.all - [Agenda.last]
    next if i < 2
    for u in users
      Factory(:participation, :participant => u, :agenda => a)
    end
  end
end

Given /^council term started a year ago$/ do
  CustomConfig['CouncilTerm']['start_time'] = 1.year.ago
end

Then /^I should see list of all council members with proper indication of their attendance$/ do
  start = CustomConfig['CouncilTerm']['start_time']
  stop = Agenda.current.meeting_time - 1.minute
  for user in User.council_member_is(true)
    Then "I should see \"#{user.name} - #{user.slacking_status_in_period(start, stop)}\" within \".collection.slacking-statuses\""
  end
end
