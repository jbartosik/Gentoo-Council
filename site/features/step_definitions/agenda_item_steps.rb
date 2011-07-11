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
  AgendaItem.new(:title => 'Rejected item', :discussion => '', :body => 'example', :rejected => true).save!
end

When /^I follow first suggested agenda link$/ do
  firstItem = AgendaItem.first :conditions => {:agenda_id => nil, :rejected => false}
  When "I follow \"#{firstItem.title}\""
end

When /^I should see current agenda as the agenda$/ do
  When "I should see \"Agenda #{Agenda.current.id}\" within \".agenda-item-agenda\""
end

Given /^agenda item in current agenda$/ do
  Agenda.create!
  AgendaItem.create! :agenda => Agenda.last, :title => 'Item in current agenda'
end

Then /^I should see "([^"]*)" button inside content body$/ do |arg1|
  within('.content-body') do
    page.all(:xpath, "//input[@type='submit'][@value='#{arg1}']").should_not be_empty
  end
end

Then /^"([^"]*)" button should be inline$/ do |arg1|
  within('.one-button-form') do
    page.all(:xpath, "//input[@type='submit'][@value='#{arg1}']").should_not be_empty
  end
end

Given /^some agenda item with discussion times$/ do
  Factory(:agenda_item)
  Factory(:agenda_item, :discussion_time => 'From 2011.07.01 to 2011.07.05, 4 full days')
  Factory(:agenda_item, :discussion_time => 'manually set')
end

Then /^I should see discussion times when viewing agenda items$/ do
  AgendaItem.all.each do |item|
    When "I am on agenda item number #{item.id} show page"
    Then "I should see \"#{item.discussion_time}\""
  end
end

Then /^I should see hint on timelimits format$/ do
  Then 'I should see "Enter reminders for this item. Each line should be a ' +
        'separate reminder in \'mm:ss <reminder message>\' format" within ".input-help"'
end
