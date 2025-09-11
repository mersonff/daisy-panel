# frozen_string_literal: true

module AuthenticationHelpers
  # Helper method for request tests that need to sign in via HTTP
  def sign_in_user(user)
    post user_session_path, params: {
      user: {
        email: user.email,
        password: 'password123'
      }
    }
    follow_redirect!
  end

  # Helper method for request tests that need to sign out
  def sign_out_user
    delete destroy_user_session_path
  end

  # Helper method for feature tests using Capybara
  def sign_in_with_capybara(user)
    visit new_user_session_path
    fill_in 'E-mail', with: user.email
    fill_in 'Senha', with: 'password123'
    click_button 'Login'
  end

  # Helper method to create and sign in an admin user
  def sign_in_admin
    admin = create(:user, admin: true)
    sign_in admin
    admin
  end

  # Helper method to create and sign in a regular user
  def sign_in_regular_user
    user = create(:user)
    sign_in user
    user
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
  config.include AuthenticationHelpers, type: :feature
  config.include AuthenticationHelpers, type: :controller
end
