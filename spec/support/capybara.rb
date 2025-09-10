require 'selenium/webdriver'

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV['CI'].present?
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        options.add_argument('--disable-gpu')
        options.add_argument('--remote-debugging-port=9222')
        options.add_argument('--window-size=1400,1400')
      end
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
    end
  end
end

# Configure Capybara for feature tests
Capybara.configure do |config|
  config.server = :puma, { Silent: true }
  config.default_max_wait_time = 5
end
