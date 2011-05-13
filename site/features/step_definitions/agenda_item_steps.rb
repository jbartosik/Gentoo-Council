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
  AgendaItem.new(:title => 'Rejected', :discussion => '', :body => 'example', :rejected => true).save!
end

When /^I follow first suggested agenda link$/ do
  firstItem = AgendaItem.first :conditions => {:agenda_id => nil, :rejected => false}
  When "I follow \"#{firstItem.title}\""
end

When /^I should see current agenda as the agenda$/ do
  When "I should see \"Agenda #{Agenda.current.id}\" within \".agenda-item-agenda\""
end
