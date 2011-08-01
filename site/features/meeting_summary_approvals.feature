Feature: Meeting summary approvals
  As council member I want to prepare meeting summaries
  And I want other council members to approve them
  So they will become public only when majority of council approves

  Scenario: Write meeting summary
    Given I am logged in as a council member
    When I am on the current agenda page
    And I follow "Edit"
    And I fill in "agenda[summary]" with "some summary"
    And I press "Save"
    Then I should see "some summary" as summary

  Scenario: Approve meeting summary, then remove approval
    Given I am logged in as a council member
    When current agenda has a summary
    And I am on the current agenda page
    And I press "approve summary"
    Then I should see "The Approval was created successfully" in the notices

    When I am on the current agenda page
    Then I should see "Summary for this agenda was approved by 1 council member(s): Example."

    When I press "remove your approval for this summary"
    And I confirm

    When I am on the current agenda page
    Then I should not see "Summary for this agenda was approved"
