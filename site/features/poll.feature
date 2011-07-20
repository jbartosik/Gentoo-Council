Feature: As council member
  I want to vote in automatically created polls
  To make planning meetings easier

  Scenario: View meeting time polls and vote
    Given I am logged in as a council member
    When I am on the current agenda page
    And I follow "Meeting day poll"
    Then I should see suggested meeting times

    When I check some boxes
    And press "Update choice"

    Then I should see my times marked
