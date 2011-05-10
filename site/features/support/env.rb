require 'cucumber/rails'
Capybara.default_selector = :css
Capybara.default_driver = :selenium
ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :transaction
