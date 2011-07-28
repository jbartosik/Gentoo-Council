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

{
  'as current agenda' => '.current-agenda',
  'as agenda state' => '.state-tag.view.agenda-state',
  'as transition' => '.transition',
  'inside content body' => '.content-body',
  'in the notices' => '.flash.notice',
  'in the errors' => '.error-messages',
  'in the agenda items' => '.agenda-items',
  'in the agendas collection' => '.collection.agendas',
  'as empty collection message' => '.empty-collection-message',
  'as meeting time' => '.meeting-time-view',
  'as proxy' => '.collection.proxies.proxies-collection',
  'as the user nick' => '.user-irc-nick',
  'as summary' => '.agenda-summary',
  'as voting option' => '.collection.voting-options',
  'as voting option description' => '.voting-option-description'
}.
each do |within, selector|
  Then /^I should( not)? see "([^"]*)" #{within}$/ do |negation, text|
    Then %Q{I should#{negation} see "#{text}" within "#{selector}"}
  end
end
