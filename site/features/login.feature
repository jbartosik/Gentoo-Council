Feature: Login
  In order to use site
  I want to be able to login

  Scenario: Email + password login
    Given example user
    When I am on the homepage
    When I follow "Login"
    Then I should be on the login page
    When I login as example user
    Then I should see "You have logged in."

  Scenario: Login, then look around and see you're still logged in
    Given example user
    When I am on the login page
    And I login as example user
    When I follow "Logged in as Example"
    Then I should see "Log out"

  Scenario: Do not remember log in if "Remeber me" field was not checked
    Given example user
    When I am on the login page
    And I uncheck "remember_me"
    And I login as example user
    When I close browser
    And I am on the home page
    Then I should see "Login"

  Scenario: Remember log in if "Remeber me" field was checked
    Given example user
    When I am on the login page
    And I check "remember_me"
    And I login as example user
    When I close browser
    And I am on the home page
    Then I should see "Log out"
