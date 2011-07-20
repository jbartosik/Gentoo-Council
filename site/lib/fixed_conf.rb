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

if Object.const_defined? :CustomConfig
  if CustomConfig.is_a? Hash
    CustomConfig.clear
  else
    puts "Warning constant CustomConfig is defined and is not a Hash. Something is wrong."
    CustomConfig = {}
  end
else
  CustomConfig = {}
end

CustomConfig['CouncilTerm'] = {}
CustomConfig['CouncilTerm']['start_time'] = 1.year.ago
CustomConfig['CouncilTerm']['min_days_between_meetings'] = 7
CustomConfig['CouncilTerm']['days_for_meeting'] = 7
CustomConfig['Reminders'] = {}
CustomConfig['Reminders']['hours_before_meeting_to_send_irc_reminders'] = 2
CustomConfig['Reminders']['hours_before_meeting_to_send_email_reminders'] = 2
