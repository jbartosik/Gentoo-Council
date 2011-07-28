Feature: Hints
  As user
  I want to see hints in forms
  So I will know what I enter

  Scenario: Agenda hints
    Given I am logged in as a council member
    When I am on the current agenda page
    And I follow "Edit"
    Then I should see "Email reminders will be sent only if this field is unchecked."

  Scenario: Agenda item hints
    Given I am logged in as a council member
    When I follow "Suggest agenda item"
    Then I should see "If you set it to 'No Agenda available.' it will be listed as 'Suggested item'"
    Then I should see "You can use markdown in the body of agenda item"
    Then I should see "Best choice is address of first message in discussion on archives.gentoo.org."
    Then I should see "If you provide address on archives.gentoo.org in discussion field application will manage this field on it's own."
    Then I should see "Rejected items are not shown on Suggested Items list. You don't have to go to edit page of item to reject it - there is a Reject button on item show page"
    Then I should see "Enter reminders for this item. Each line should be a separate reminder in 'mm:ss <reminder message>' format"

  Scenario: User hints
    When I am on the home page
    And I follow "Signup"
    Then I should see "Nick you use on freenode (it's important if you are council member)."
