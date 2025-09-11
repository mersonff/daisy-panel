require 'rails_helper'

RSpec.describe "Admin Dashboard", type: :feature do
  include ActiveSupport::Testing::TimeHelpers
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  before do
    sign_in_with_capybara(user)
  end

  describe "dashboard overview" do
    before do
      # Create test data for the user
      create_list(:client, 3, user: user)
      create_list(:appointment, 2, user: user)
      create(:appointment, user: user, start_time: Date.current.beginning_of_day + 10.hours, end_time: Date.current.beginning_of_day + 11.hours)

      # Create data for other user (should not appear)
      create(:client, user: other_user)
      create(:appointment, user: other_user)

      visit admin_root_path
    end

    it "displays the correct statistics" do
      expect(page).to have_content("Total de Clientes")
      expect(page).to have_content("3") # user's clients only

      expect(page).to have_content("Total de Compromissos")
      expect(page).to have_content("3") # user's appointments only

      expect(page).to have_content("Compromissos Hoje")
      expect(page).to have_content("1") # today's appointments
    end

    it "displays navigation cards with correct links" do
      expect(page).to have_link("Ver Todos", href: admin_clients_path)
      expect(page).to have_link("Adicionar", href: new_admin_client_path)
      expect(page).to have_link("Ver Todos", href: admin_appointments_path)
      expect(page).to have_link("Agendar", href: new_admin_appointment_path)
    end

    it "displays chart containers" do
      expect(page).to have_css("#clientsChart")
      expect(page).to have_css("#appointmentsChart")
    end

    it "displays main action buttons" do
      expect(page).to have_link("Cadastrar Cliente", href: new_admin_client_path)
      expect(page).to have_link("Novo Compromisso", href: new_admin_appointment_path)
      expect(page).to have_link("Importar CSV", href: admin_clients_path)
      expect(page).to have_link("Ver Relatórios", href: admin_import_reports_path)
    end
  end

  describe "charts functionality", js: true do
    before do
      # Create clients at different dates for chart data
      travel_to 10.days.ago do
        create_list(:client, 2, user: user)
      end
      travel_to 5.days.ago do
        create(:client, user: user)
      end

      # Create appointments at different dates
      travel_to 8.days.ago do
        create(:appointment, user: user)
      end
      travel_to 3.days.ago do
        create(:appointment, user: user)
      end

      visit admin_root_path
    end

    it "loads client chart data successfully" do
      # Wait for charts to load
      sleep 2

      # Check if chart containers have content (not loading text)
      expect(page).not_to have_content("Carregando gráfico...")

      # Verify chart canvas elements are created
      expect(page).to have_css("#clientsChart canvas")
    end

    it "loads appointment chart data successfully" do
      # Wait for charts to load
      sleep 2

      # Check if chart containers have content (not loading text)
      expect(page).not_to have_content("Carregando gráfico...")

      # Verify chart canvas elements are created
      expect(page).to have_css("#appointmentsChart canvas")
    end
  end

  describe "responsive design" do
    it "displays correctly" do
      visit admin_root_path

      expect(page).to have_content("Painel Administrativo")
      expect(page).to have_css(".stats")
    end
  end

  describe "import status" do
    let!(:import_report) { create(:import_report, user: user, success_count: 5, error_count: 1) }

    it "displays import statistics when available" do
      visit admin_root_path

      expect(page).to have_content("Última Importação")
      expect(page).to have_content("5 sucessos, 1 erro")
    end
  end

  describe "user isolation" do
    it "only shows data belonging to the current user" do
      # Create data for current user
      create_list(:client, 2, user: user, state: "SP")
      create(:appointment, user: user)

      # Create data for other user
      create_list(:client, 5, user: other_user, state: "RJ")
      create_list(:appointment, 3, user: other_user)

      visit admin_root_path

      # Should only see current user's data
      expect(page).to have_content("Total de Clientes")
      expect(page).to have_content("2") # only user's clients

      expect(page).to have_content("Total de Compromissos")
      expect(page).to have_content("1") # only user's appointments
    end
  end

  describe "error handling" do
    it "handles chart loading errors gracefully", js: true do
      # Mock a failed API request
      allow_any_instance_of(Admin::DashboardController).to receive(:clients_chart_data).and_raise(StandardError)

      visit admin_root_path

      # Should not crash the page
      expect(page).to have_content("Painel Administrativo")
    end
  end
end
