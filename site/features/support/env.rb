require 'cucumber/rails'
Capybara.default_selector = :css
Capybara.default_driver = :webkit
ActionController::Base.allow_rescue = false
DatabaseCleaner.strategy = :transaction
