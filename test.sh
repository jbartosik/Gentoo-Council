#!/bin/sh
function run_test {
  if $1 $2
  then
    date +"%Y-%m-%d %H:%M:%S Test of $3 was succesfull" >>tests.log
  else
    date +"%Y-%m-%d %H:%M:%S Test of $3 failed" >>tests.log
  fi
}
run_test python bot/tests/run_test.py MeetBot
run_test python bot/Reminder/run_test.py Reminder
pushd site
bundle exec rails g hobo:rapid
run_test "bundle exec" "rake" WebApp
popd
