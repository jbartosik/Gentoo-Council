Feature:  Application side of voting
  In order to handle voting with IRC bot
  I want application to help with that

  Scenario: Add voting option
    Given example agenda item
    And an agenda
    And some council members
    And I am logged in as council member
    When I am on the current agenda page
    And I follow first agenda item link
    And I add example voting option
    Then I should see "example" as voting option

  Scenario: Edit voting option
    Given example voting option
    Given an agenda
    And some council members
    And I am logged in as council member
    When I go from the homepage to edit last voting option page
    And I fill in "voting_option_description" with "some description"
    And I press "Save Voting option"
    Then I should see "some description" as voting option description

  Scenario: Vote as regular user
    Given I am logged in as example user
    And there is an item with some voting options for current agenda
    When I am on the newest agenda item page
    And I follow "Vote"
    Then I should see my vote

  Scenario: View community vote results
    Given there is an item with some voting options for current agenda
    And some community and council votes for a newer item
    When I am on the newest agenda item page
    Then I should see correct community votes
