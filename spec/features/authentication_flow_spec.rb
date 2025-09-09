require 'rails_helper'

RSpec.feature "Authentication Flow", type: :feature do
  let(:user) { create(:user) }

  feature "User login" do
    scenario "displays the login form" do
      visit new_user_session_path
      
      expect(page).to have_field("E-mail")
      expect(page).to have_field("Senha")
      expect(page).to have_button("Login")
      expect(page).to have_field("Lembre-se de mim")
    end

    context "with valid credentials" do
      scenario "logs in successfully and redirects to admin dashboard" do
        visit new_user_session_path
        
        fill_in "E-mail", with: user.email
        fill_in "Senha", with: "password123"
        click_button "Login"
        
        expect(page).to have_current_path(dashboard_path)
        expect(page).to have_content("Login efetuado com sucesso")
      end

      scenario "remembers the user when 'Lembrar de mim' is checked" do
        visit new_user_session_path
        
        fill_in "E-mail", with: user.email
        fill_in "Senha", with: "password123"
        check "Lembre-se de mim"
        click_button "Login"
        
        expect(page).to have_current_path(dashboard_path)
      end
    end

    context "with invalid credentials" do
      scenario "shows error message for wrong email" do
        visit new_user_session_path
        
        fill_in "E-mail", with: "wrong@example.com"
        fill_in "Senha", with: "password123"
        click_button "Login"
        
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("E-mail ou senha inválidos")
      end

      scenario "shows error message for wrong password" do
        visit new_user_session_path
        
        fill_in "E-mail", with: user.email
        fill_in "Senha", with: "wrongpassword"
        click_button "Login"
        
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("E-mail ou senha inválidos")
      end

      scenario "shows error message for empty fields" do
        visit new_user_session_path
        
        click_button "Login"
        
        expect(page).to have_current_path(user_session_path)
        expect(page).to have_content("E-mail ou senha inválidos")
      end
    end
  end

  feature "User logout" do
    scenario "logs out successfully" do
      sign_in user
      visit dashboard_path
      
      # Click on user avatar dropdown (more semantic approach)
      find('.dropdown .btn.avatar').click
      click_button "Sair"
      
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Logout efetuado com sucesso")
    end
  end

  feature "Protected pages" do
    context "when not logged in" do
      scenario "redirects admin dashboard to login" do
        visit dashboard_path
        
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("Para continuar")
      end

      scenario "redirects profile edit to login" do
        visit edit_user_registration_path
        
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("Para continuar")
      end
    end

    context "when logged in" do
      before { sign_in user }

      scenario "allows access to admin dashboard" do
        visit dashboard_path
        
        expect(page).to have_current_path(dashboard_path)
      end

      scenario "allows access to profile edit" do
        visit edit_user_registration_path
        
        expect(page).to have_current_path(edit_user_registration_path)
      end
    end
  end

  feature "Registration blocking" do
    scenario "redirects registration page to login with error message" do
      visit new_user_registration_path
      
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("Registro público não permitido")
    end
  end

  feature "Flash messages" do
    scenario "displays flash message with close button" do
      visit new_user_session_path
      
      fill_in "E-mail", with: user.email
      fill_in "Senha", with: "wrongpassword"
      click_button "Login"
      
      expect(page).to have_css('.alert-error')
      expect(page).to have_content("E-mail ou senha inválidos")
    end
  end

  feature "Navigation" do
    before { sign_in user }

    scenario "displays navigation menu" do
      visit dashboard_path
      
      expect(page).to have_css('.navbar')
      expect(page).to have_content("Daisy Panel")
    end

    scenario "displays user dropdown menu" do
      visit dashboard_path
      
      find('.dropdown .btn.avatar').click
      
      expect(page).to have_content("Perfil")
      expect(page).to have_content("Sair")
    end

    scenario "navigates to profile edit page" do
      visit dashboard_path
      
      find('.dropdown .btn.avatar').click
      click_link "Perfil"
      
      expect(page).to have_current_path(edit_user_registration_path)
    end
  end
end
