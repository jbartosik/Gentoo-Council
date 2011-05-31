Feature: Proxies
  In order to check presence properly
  I want the web application
  To support proxies for council members

  Scenario: Appoint then un-appoint proxy
    Given I am logged in as a council member
    And an agenda
    When I view profile of a regular user
    And I press "Appoint as a proxy for next meeting"

    When I am on the current agenda page
    Then I should see "User for Example" as proxy

    When I press "Un-appoint proxy"
    And I confirm
    And I am on the current agenda page
    Then I should not see "User for Example"

  Scenario: Don't see useles proxy-management buttons as user who isn't a council member
    Given I am logged in as example user
    And an agenda
    When I view profile of a regular user
    Then I should not see "Appoint as a proxy" button

    Given someone appointed a proxy
    When I am on the current agenda page
    Then I should not see "Un-appoint prox" button

  Scenario: Don't see useles proxy-management buttons as user who is a council member
    Given I am logged in as a council member
    And an agenda
    And a regular user
    And someone appointed a proxy

    When I am on the "Member-who-appointed" show page
    Then I should not see "Appoint as a proxy" button

    When I am on the current agenda page
    Then I should not see "Un-appoint prox" button

    When I view old meeting for which I appointed a proxy
    Then I should not see "Un-appoint prox" button
