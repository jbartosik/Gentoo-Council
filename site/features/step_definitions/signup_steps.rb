Then /^I should see proper password entries$/ do
  page.should have_xpath("//input[@type='password'][@name='user[password]']")
  page.should have_xpath("//input[@type='password'][@name='user[password_confirmation]']")
end

When /^I fill in bad user info$/ do
  When "I fill in the following:", table(%{
    |user[name]                 |User Name      |
    |user[email]                |user@name.com  |
    |user[irc_nick]             |user           |
    |user[password]             |SomePassword   |
    |user[password_confirmation]|some_password  |
  })

end
