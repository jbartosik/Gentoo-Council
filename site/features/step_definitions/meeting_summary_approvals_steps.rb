When /^current agenda has a summary$/ do
  agenda = Agenda.current
  agenda.summary = 'Summary'
  agenda.save!
end
