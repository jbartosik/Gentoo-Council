Given /^an agenda$/ do
  Agenda.new(:meeting_time => Time.now).save!
end

Then /^I should see current date as meeting time$/ do
  Then "I should see \"#{Time.now.strftime("%Y-%m-%d")}\" as meeting time"
end

When /^I follow link to first agenda$/ do
  link_text = page.find(:xpath, "//a[contains(@class, 'agenda-link')]").text
  When "I follow \"#{link_text}\""
end
