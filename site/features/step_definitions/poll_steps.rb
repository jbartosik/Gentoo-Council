Then /^I should see suggested meeting times$/ do
  descriptions = Agenda.current.agenda_items.first.voting_options.*.description
  descriptions.each do |description|
    Then "I should see \"#{description}\""
  end
end

When /^I check some boxes$/ do
  options = Agenda.current.agenda_items.first.voting_options
  When "I check \"choice[#{options.first.id}]\""
  When "I check \"choice[#{options.last.id}]\""
end

Then /^I should see my times marked$/ do
  options = Agenda.current.agenda_items.first.voting_options
  "I should see checked checkbox with name \"#{options.first.id}\""
  "I should see checked checkbox with name \"#{options.last.id}\""
end

Then /^I should see checked checkbox with name "([^"]*)"$/ do |name|
  page.should have_xpath(:xpath, "//input[@type='checkbox'][@name='#{"choice[#{no}]"}'][@checked]")
end
