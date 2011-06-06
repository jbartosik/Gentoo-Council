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
