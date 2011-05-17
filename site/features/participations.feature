Feature: In order to track presence on the council meetings
  I want the application to store participations

  Scenario: When archiving agenda mark all council members as participants
    Given some council members
    And I am logged in as council member
    And an closed agenda
    When I am on the current agenda page
    And I archive current agenda
    Then I should see all council members as participants
