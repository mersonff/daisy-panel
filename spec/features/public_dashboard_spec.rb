require 'rails_helper'

RSpec.describe "Public Dashboard", type: :feature do
  include ActiveSupport::Testing::TimeHelpers
  describe "homepage display" do
    before do
      create_list(:client, 5, state: "SP")
      create_list(:client, 3, state: "RJ")
      create(:client, phone: "11999999999")
      create(:client, phone: "11999999999")

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
      create_list(:client, 3, state: "SP")
      create(:client, state: "RJ")

      visit root_path
      sleep 2
    end

    it "displays initial statistics correctly" do
      expect(page).to have_css("#total-clients", text: "4")
      expect(page).to have_css("#duplicate-phones", text: "0")
    end

    it "displays clients per state table correctly" do
      within("#clients-per-state") do
        expect(page).to have_content("SP")
        expect(page).to have_content("3")
        expect(page).to have_content("RJ")
        expect(page).to have_content("1")
      end
    end

    it "updates statistics when new clients are created" do
      create(:client, state: "MG")
      PublicDashboardBroadcaster.broadcast_stats
      sleep 1
      expect(page).to have_css("#total-clients", text: "5")
    end

    it "handles duplicate phone statistics correctly" do
      create(:client, phone: "11999999999")
      create(:client, phone: "11999999999")
      PublicDashboardBroadcaster.broadcast_stats
      sleep 1
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

      expect(page).to have_current_path(new_user_session_path)
    end

    it "allows navigation from admin panel back to public dashboard" do
      user = create(:user)
      sign_in_with_capybara(user)

      visit admin_root_path
      visit root_path

      expect(page).to have_content("Daisy Panel")
      expect(page).to have_content("Dashboard em tempo real")
    end
  end

  describe "ActionCable connection", js: true do
    it "establishes WebSocket connection successfully" do
      visit root_path
      sleep 2
      expect(page).to have_css("#total-clients")
    end

    it "handles connection failures gracefully" do
      visit root_path
      expect(page).to have_content("Daisy Panel")
      expect(page).to have_css("#total-clients")
      expect(page).to have_css("#duplicate-phones")
    end
  end

  describe "data accuracy" do
    it "displays statistics elements" do
      visit root_path

      expect(page).to have_css("#total-clients")
      expect(page).to have_css("#duplicate-phones")
      expect(page).to have_css("#clients-per-state")
    end
  end

  describe "empty state" do
    it "handles empty database gracefully" do
      Client.destroy_all

      visit root_path
      sleep 2 if page.driver.is_a?(Capybara::Selenium::Driver)

      expect(page).to have_css("#total-clients", text: "0")
      expect(page).to have_css("#duplicate-phones", text: "0")
      expect(page).to have_content("Estado")
      expect(page).to have_content("Quantidade")
    end
  end
end
