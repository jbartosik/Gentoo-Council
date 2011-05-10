Given /^example user$/ do
  user = User.new :name => "Example", :email => "example@example.com",
                  :password => "Example", :irc_nick => "example"
  user.save!
end

When /^I login as "([^"]*)" with password "([^"]*)"$/ do |email, password|
  When "I fill in \"login\" with \"#{email}\""
  When "I fill in \"password\" with \"#{password}\""
  When 'I press "Login"'
end

When /^I login as example user$/ do
    When 'I login as "example@example.com" with password "Example"'
end

When /^I close browser$/ do
  Capybara.current_session.driver.is_a?(Capybara::Driver::Selenium).should be_true
  browser = Capybara.current_session.driver.browser
  browser.manage.all_cookies.each do |cookie|
    if cookie[:expires].nil? || cookie[:expires] < Time.now
      browser.manage.delete_cookie(cookie[:name])
    end
  end
end
