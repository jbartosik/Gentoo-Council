Feature: IRC nick
  In order to make IRC bot integration possible
  I want all users to provide their freenode IRC nicks

  Scenario: User registration with nick
    When I am on the homepage
    And I follow "Signup"
    And I signup as example user with IRC nick
    Then I should see "Thanks for signing up!" in the notices

  Scenario: Fail user registration without nick
    When I am on the signup page
    And I signup as example user without IRC nick
    Then I should see "Irc nick can't be blank" in the errors
    And I should be on the signup page

  Scenario: View your own IRC nick
    Given I am logged in as example user
    When I follow "Logged in as Example"
    Then I should see "example" as the user nick
