When /^I follow first agenda item link$/ do
  When "I follow \"#{AgendaItem.first.title}\""
end

When /^I add example voting option$/ do
  When 'I fill in "voting_option_description" with "example"'
  When 'I press "Add a voting option"'
end

Given /^example voting option$/ do
  Given 'example agenda item'
  VotingOption.new(:description => 'example', :agenda_item => AgendaItem.last).save!
end

When /^I go from the homepage to edit last voting option page$/ do
  When 'I am on the homepage'
  When 'I follow "Agendas"'
  When 'I follow link to current agenda'
  When "I follow \"#{AgendaItem.last.title}\""
  When "I follow \"#{VotingOption.last.description}\""
  When 'I follow "Edit Voting option"'
end
