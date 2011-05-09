{
  'in the notices' => '.flash.notice',
  'in the errors' => '.error-messages',
  'as the user nick' => '.user-irc-nick'
}.
each do |within, selector|
  Then /^I should( not)? see "([^"]*)" #{within}$/ do |negation, text|
    Then %Q{I should#{negation} see "#{text}" within "#{selector}"}
  end
end
