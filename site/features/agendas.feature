Feature: Agendas
  In order to manage meetings
  I want to have agendas

  Scenario: View agendas listing as a guest
    When I am on the homepage
    And I follow "Agendas"
    Then I should not see "Agenda" in the content body

    Given an agenda
    When I follow "Agendas"
    Then I should see "Agenda" in the agendas collection

    When I follow link to first agenda
    Then I should see current date as meeting time
