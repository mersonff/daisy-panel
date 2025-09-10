require 'rails_helper'

RSpec.feature "Import Reports", type: :feature do
  let(:user) { create(:user) }
  let!(:import_report1) { create(:import_report, user: user, created_at: 2.days.ago, total_lines: 10, success_count: 7, error_count: 3, status: 'completed', filename: 'clients_old.csv') }
  let!(:import_report2) { create(:import_report, user: user, created_at: 1.day.ago, total_lines: 5, success_count: 5, error_count: 0, status: 'completed', filename: 'clients_new.csv') }
  let!(:other_user_report) { create(:import_report, user: create(:user), filename: 'other_user_file.csv') }

  before do
    sign_in_with_capybara(user)
  end

  scenario "User views import reports list" do
    visit admin_import_reports_path

    expect(page).to have_content("Relatórios de Importação")
    expect(page).to have_content("Ver Detalhes")
    expect(page).to have_content("10") # total_lines from import_report1
    expect(page).to have_content("5")  # total_lines from import_report2
    expect(page).not_to have_content(other_user_report.filename)
  end

  scenario "User views most recent reports first" do
    visit admin_import_reports_path

    # Check that table rows exist and are ordered correctly
    rows = page.all('tbody tr')
    expect(rows.count).to be >= 2

    # Most recent should be first (import_report2)
    expect(rows.first).to have_content("5") # total_lines of import_report2
    expect(rows.last).to have_content("10") # total_lines of import_report1
  end

  scenario "User views import report details" do
    error_details = [
      { "line" => 2, "name" => "João Silva", "cpf" => "12345678900", "errors" => [ "Nome inválido" ] },
      { "line" => 3, "name" => "Maria Santos", "cpf" => "09876543211", "errors" => [ "CPF inválido" ] }
    ]
    import_report1.update(error_details: error_details)

    visit admin_import_report_path(import_report1)

    expect(page).to have_content("Detalhes da Importação")
    expect(page).to have_content("10") # Total de Linhas
    expect(page).to have_content("7")  # Sucessos
    expect(page).to have_content("3")  # Erros
    expect(page).to have_content("70,0%") # Taxa de sucesso formatted
    expect(page).to have_content("30,0%") # Taxa de erro formatted

    expect(page).to have_content("2") # Linha 2
    expect(page).to have_content("João Silva")
    expect(page).to have_content("Nome inválido")

    expect(page).to have_content("3") # Linha 3
    expect(page).to have_content("Maria Santos")
    expect(page).to have_content("CPF inválido")
  end

  scenario "User cannot access other user's reports" do
    visit admin_import_report_path(other_user_report)

    expect(page).to have_current_path(admin_clients_path)
  end

  scenario "User accesses latest import report" do
    visit latest_admin_import_reports_path

    expect(page).to have_current_path(admin_import_report_path(import_report2))
  end

  scenario "User with no reports is redirected with notice" do
    user.import_reports.destroy_all

    visit latest_admin_import_reports_path

    expect(page).to have_current_path(admin_clients_path)
    expect(page).to have_content("Nenhuma importação encontrada.")
  end

  scenario "User navigates back to clients from report" do
    visit admin_import_report_path(import_report1)

    click_link "Voltar para Clientes"

    expect(page).to have_current_path(admin_clients_path)
  end

  scenario "User sees table with import reports" do
    visit admin_import_reports_path

    # Should show table headers
    expect(page).to have_content("Data/Hora")
    expect(page).to have_content("Arquivo")
    expect(page).to have_content("Status")
    expect(page).to have_content("Total de Linhas")
    expect(page).to have_content("Sucessos")
    expect(page).to have_content("Erros")
    expect(page).to have_content("Taxa de Sucesso")
    expect(page).to have_content("Ações")

    # Should show data rows
    expect(page).to have_css('tbody tr', count: 2)
  end

  context "when user is not signed in" do
    before { sign_out user }

    scenario "redirects to login page for index" do
      visit admin_import_reports_path

      expect(page).to have_current_path(new_user_session_path)
    end

    scenario "redirects to login page for show" do
      visit admin_import_report_path(import_report1)

      expect(page).to have_current_path(new_user_session_path)
    end

    scenario "redirects to login page for latest" do
      visit latest_admin_import_reports_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
