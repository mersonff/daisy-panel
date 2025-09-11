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
      create_list(:client, 3, user: user)
      create_list(:appointment, 2, user: user)
      create(:appointment, user: user, start_time: Date.current.beginning_of_day + 10.hours, end_time: Date.current.beginning_of_day + 11.hours)

      create(:client, user: other_user)
      create(:appointment, user: other_user)

      visit admin_root_path
    end

    it "displays the correct statistics" do
      expect(page).to have_content("Total Clientes")
      expect(page).to have_content("3")

      expect(page).to have_content("Compromissos")
      expect(page).to have_content("3")

      expect(page).to have_content("Hoje")
      expect(page).to have_content("1")
    end

    it "displays navigation cards with correct links" do
      expect(page).to have_link("Gerenciar")
      expect(page).to have_link("Adicionar")
      expect(page).to have_link("Agendar")
      expect(page).to have_link("Importar")
    end

    it "displays chart containers" do
      expect(page).to have_css("#clientsChart")
      expect(page).to have_css("#appointmentsChart")
    end

    it "displays main action buttons" do
      expect(page).to have_content("Importar CSV")
      expect(page).to have_content("Adicionar Cliente")
      expect(page).to have_content("Gerenciar Clientes")
      expect(page).to have_content("Novo Compromisso")
      expect(page).to have_content("Gerenciar Compromissos")
    end
  end

  describe "charts functionality" do
    it "displays chart containers" do
      visit admin_root_path

      expect(page).to have_css("#clientsChart")
      expect(page).to have_css("#appointmentsChart")
      expect(page).to have_content("Clientes Cadastrados (30 dias)")
      expect(page).to have_content("Compromissos Criados (30 dias)")
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

    it "displays import section" do
      visit admin_root_path

      expect(page).to have_content("Importações")
      expect(page).to have_content("CSV processados")
    end
  end

  describe "user isolation" do
    it "only shows data belonging to the current user" do
      create_list(:client, 2, user: user, state: "SP")
      create(:appointment, user: user)

      create_list(:client, 5, user: other_user, state: "RJ")
      create_list(:appointment, 3, user: other_user)

      visit admin_root_path

      expect(page).to have_content("Total Clientes")
      expect(page).to have_content("2")

      expect(page).to have_content("Compromissos")
      expect(page).to have_content("1")
    end
  end

  describe "error handling" do
    it "displays basic dashboard structure" do
      visit admin_root_path

      expect(page).to have_content("Painel Administrativo")
      expect(page).to have_css(".stats")
    end
  end
end
