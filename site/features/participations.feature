Feature: In order to track presence on the council meetings
  I want the application to store participations

  Scenario: When archiving agenda mark all council members as participants
    Given some council members
    And an agenda
    And I am logged in as council member
    When application got voting results from IRC bot
    And I am on the current agenda page
    Then I should see some council members as participants
