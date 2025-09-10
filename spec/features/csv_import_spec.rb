require 'rails_helper'

RSpec.feature "CSV Import", type: :feature, js: true do
  let(:user) { create(:user) }

  before do
    sign_in_with_capybara(user)
  end

  scenario "User can see the CSV import button" do
    visit admin_clients_path

    expect(page).to have_button("Importar CSV")
  end

  scenario "User can open the CSV import modal" do
    visit admin_clients_path

    click_button "Importar CSV"

    expect(page).to have_content("Importar Clientes via CSV")
    expect(page).to have_content("Selecione o arquivo CSV")
    expect(page).to have_button("Selecionar arquivo")
    expect(page).to have_button("Cancelar")
    expect(page).to have_button("Importar Arquivo", disabled: true)
  end

  scenario "User can close the CSV import modal" do
    visit admin_clients_path

    click_button "Importar CSV"
    expect(page).to have_content("Importar Clientes via CSV")

    click_button "Cancelar"
    expect(page).not_to have_content("Importar Clientes via CSV")
  end

  private

  def create_temp_csv_file(content)
    Tempfile.new([ 'test', '.csv' ]).tap do |file|
      file.write(content)
      file.rewind
    end
  end
end
