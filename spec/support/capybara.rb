# frozen_string_literal: true

require 'capybara/rails'
require 'capybara/rspec'

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome,
                                      options: Selenium::WebDriver::Chrome::Options.new(args: ['--no-sandbox']))
end

Capybara.register_driver :selenium_chrome_headless do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome,
                                      options: Selenium::WebDriver::Chrome::Options.new(args: %w[headless disable-gpu no-sandbox]))
end

Capybara.javascript_driver = :selenium_chrome
