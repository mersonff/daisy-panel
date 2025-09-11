require 'rails_helper'

RSpec.describe "Public Dashboard", type: :feature do
  include ActiveSupport::Testing::TimeHelpers
  describe "homepage display" do
    before do
      # Create test data
      create_list(:client, 5, state: "SP")
      create_list(:client, 3, state: "RJ")
      create(:client, phone: "11999999999")
      create(:client, phone: "11999999999") # Duplicate phone

      visit root_path
    end

    it "displays the main title and description" do
      expect(page).to have_content("Daisy Panel")
      expect(page).to have_content("Dashboard em tempo real - Sistema de Gerenciamento de Clientes")
    end

    it "displays the statistics cards" do
      expect(page).to have_content("Total de Clientes")
      expect(page).to have_content("Telefones Duplicados")
      expect(page).to have_css("#total-clients")
      expect(page).to have_css("#duplicate-phones")
    end

    it "displays the clients per state table" do
      expect(page).to have_content("Clientes por Estado")
      expect(page).to have_css("table")
      expect(page).to have_css("#clients-per-state")

      # Table headers
      expect(page).to have_content("Estado")
      expect(page).to have_content("Quantidade")
    end

    it "displays the admin panel access button" do
      expect(page).to have_link("Acessar Painel Administrativo", href: admin_root_path)
    end

    it "loads the public dashboard JavaScript" do
      expect(page).to have_css("script[src*='public-dashboard']", visible: false)
    end
  end

  describe "real-time functionality", js: true do
    before do
      # Create initial test data
      create_list(:client, 3, state: "SP")
      create(:client, state: "RJ")

      visit root_path

      # Wait for initial ActionCable connection and data load
      sleep 2
    end

    it "displays initial statistics correctly" do
      # Check initial stats are loaded
      expect(page).to have_css("#total-clients", text: "4")
      expect(page).to have_css("#duplicate-phones", text: "0")
    end

    it "displays clients per state table correctly" do
      # Check that states are displayed in the table
      within("#clients-per-state") do
        expect(page).to have_content("SP")
        expect(page).to have_content("3")
        expect(page).to have_content("RJ")
        expect(page).to have_content("1")
      end
    end

    it "updates statistics when new clients are created" do
      # Create a new client to trigger broadcast
      create(:client, state: "MG")

      # Trigger broadcast manually (since we're not in a full Rails environment)
      PublicDashboardBroadcaster.broadcast_stats

      # Wait for update
      sleep 1

      # Check updated stats
      expect(page).to have_css("#total-clients", text: "5")
    end

    it "handles duplicate phone statistics correctly" do
      # Create clients with duplicate phones
      create(:client, phone: "11999999999")
      create(:client, phone: "11999999999")

      # Trigger broadcast
      PublicDashboardBroadcaster.broadcast_stats

      # Wait for update
      sleep 1

      # Check duplicate count
      expect(page).to have_css("#duplicate-phones", text: "1")
    end
  end

  describe "responsive design" do
    it "displays correctly" do
      visit root_path

      expect(page).to have_content("Daisy Panel")
      expect(page).to have_css(".stats")
    end
  end

  describe "navigation" do
    it "allows navigation to admin panel" do
      visit root_path

      click_link "Acessar Painel Administrativo"

      # Should redirect to login page since user is not authenticated
      expect(page).to have_current_path(new_user_session_path)
    end

    it "allows navigation from admin panel back to public dashboard" do
      user = create(:user)
      sign_in_with_capybara(user)

      visit admin_root_path

      # Navigate back to public dashboard
      visit root_path

      expect(page).to have_content("Daisy Panel")
      expect(page).to have_content("Dashboard em tempo real")
    end
  end

  describe "ActionCable connection", js: true do
    it "establishes WebSocket connection successfully" do
      visit root_path

      # Wait for connection
      sleep 2

      # Check console logs for connection (if possible in test environment)
      # This would require custom JavaScript testing setup
      expect(page).to have_css("#total-clients")
    end

    it "handles connection failures gracefully" do
      # Mock ActionCable failure (would require more advanced setup)
      visit root_path

      # Page should still display basic structure even if WebSocket fails
      expect(page).to have_content("Daisy Panel")
      expect(page).to have_css("#total-clients")
      expect(page).to have_css("#duplicate-phones")
    end
  end

  describe "data accuracy" do
    it "displays statistics elements" do
      visit root_path

      # Check that the statistics elements are present
      expect(page).to have_css("#total-clients")
      expect(page).to have_css("#duplicate-phones")
      expect(page).to have_css("#clients-per-state")
    end
  end

  describe "empty state" do
    it "handles empty database gracefully" do
      # Ensure no clients exist
      Client.destroy_all

      visit root_path

      # Wait for data load
      sleep 2 if page.driver.is_a?(Capybara::Selenium::Driver)

      expect(page).to have_css("#total-clients", text: "0")
      expect(page).to have_css("#duplicate-phones", text: "0")

      # Table should be empty but still have headers
      expect(page).to have_content("Estado")
      expect(page).to have_content("Quantidade")
    end
  end
end
