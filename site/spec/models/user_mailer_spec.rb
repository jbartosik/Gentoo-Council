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

require 'spec_helper'
describe UserMailer do
  it 'should send proper meeting reminders' do
    user = Factory(:user)
    agenda = Factory(:agenda)
    reminder = UserMailer.meeting_reminder(user, agenda)
    reminder.should deliver_to(user.email)
    reminder.should deliver_from("no-reply@localhost")
    reminder.should have_text(/meeting will take place on #{agenda.meeting_time.to_s}./)
    reminder.should have_text(/You can view agenda for the meeting on:/)
    reminder.should have_text(/http:\/\/localhost:3000\/agendas\/#{agenda.id}/)
    reminder.should have_subject("Upcoming meeting reminder - #{agenda.meeting_time.to_s}")
  end
end
