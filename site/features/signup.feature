Feature: Singup
  As user I want to be able to signup
  And do it properly

  Scenario: Always show password as in password type inputs
    When I am on the homepage
    And I follow "Signup"
    Then I should see proper password entries

    When I fill in bad user info
    And I press "Signup"
    Then I should see proper password entries
