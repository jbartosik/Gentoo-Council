{
  'as current agenda' => '.current-agenda',
  'as agenda state' => '.state-tag.view.agenda-state',
  'as transition' => '.transition',
  'in the notices' => '.flash.notice',
  'in the errors' => '.error-messages',
  'in the content body' => '.content-body',
  'in the agenda items' => '.agenda-items',
  'in the agendas collection' => '.collection.agendas',
  'as empty collection message' => '.empty-collection-message',
  'as meeting time' => '.meeting-time-view',
  'as proxy' => '.collection.proxies.proxies-collection',
  'as the user nick' => '.user-irc-nick',
  'as voting option' => '.collection.voting-options',
  'as voting option description' => '.voting-option-description'
}.
each do |within, selector|
  Then /^I should( not)? see "([^"]*)" #{within}$/ do |negation, text|
    Then %Q{I should#{negation} see "#{text}" within "#{selector}"}
  end
end
