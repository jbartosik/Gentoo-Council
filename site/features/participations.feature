Feature: In order to track presence on the council meetings
  I want the application to store participations

  Scenario: When archiving agenda mark all council members as participants
    Given some council members
    And an agenda
    And I am logged in as council member
    When application got voting results from IRC bot
    And I am on the current agenda page
    Then I should see some council members as participants

  Scenario: View council slacking status
    Given council term started a year ago
    And some agendas
    And some council members who attended properly
    And some council members who skipped last meeting
    And some slackers
    And some slackers who skipped a meeting
    When I am on the home page
    And I follow "Current council attendance"
    Then I should see list of all council members with proper indication of their attendance
