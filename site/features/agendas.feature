Feature: Agendas
  In order to manage meetings
  I want to have agendas

  Scenario: View agendas listing as a guest
    Given an agenda
    Given an old agenda
    When I am on the homepage
    And I follow "Agendas"
    Then I should see "Agenda" in the agendas collection
    And I should see "Agenda" as current agenda

    When I follow link to first agenda
    Then I should see current date as meeting time

  Scenario: Change current agenda state as a council member
    Given an agenda
    When I am logged in as a council member
    And I follow "Agendas"
    And I follow link to current agenda
    Then I should see "open" as agenda state
    And I should see "Close this agenda" as transition

    When I close current agenda
    Then I should see "submissions_closed" as agenda state
    And I should see "Reopen this agenda" as transition
    And I should see "Archive this agenda" as transition

    When I reopen current agenda
    Then I should see "open" as agenda state

    When I close current agenda
    When I archive current agenda
    Then I should see "old" as agenda state

  Scenario: Change current agenda state as a council member
    Given an closed agenda
    When I am logged in as a council member
    And I am on the current agenda page
    And I archive current agenda

    When I follow "Agendas"
    And I follow link to current agenda
    Then I should see "open" as agenda state
