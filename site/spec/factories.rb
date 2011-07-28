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

Factory.sequence :user do |n|
    "user-#{n}"
end

Factory.define :user, :class => User do |u|
  u.name { Factory.next(:user) }
  u.irc_nick { Factory.next(:user) }
  u.email { |u| "#{u.name}@example.com" }
end

Factory.define :agenda do |a|; end

Factory.define :agenda_item do |a|
  a.sequence(:title) { |n| "Agenda Item #{n}" }
end

Factory.define :participation do |p|; end

Factory.define :vote do |v|;
  v.association :voting_option
  v.user        { users_factory(:council) }
end

Factory.define :voting_option  do |v|;
  v.agenda_item { AgendaItem.create! }
  v.description { "example" }
end

Factory.define :proxy do |p|;
  p.council_member  {users_factory(:council)}
  p.proxy           {users_factory(:user)}
  p.agenda          {Factory(:agenda)}
end

Factory.define :approval do |a|;
 a.user {users_factory(:council)}
 a.agenda {Agenda.current}
end

require File.expand_path("../support/users_factory.rb", __FILE__)
