require 'rails_helper'

RSpec.configure do |config|
  Capybara.javascript_driver = :poltergeist
  Capybara.ignore_hidden_elements = true

  config.include FeatureMacros, type: :feature

  config.use_transactional_fixtures = false

  #Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
