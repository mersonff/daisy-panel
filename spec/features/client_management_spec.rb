require 'rails_helper'

RSpec.feature 'Client Management', type: :feature do
  let(:user) { create(:user) }
  let!(:client) { create(:client, user: user, name: 'João Silva') }

  before do
    sign_in_with_capybara(user)
  end

  scenario 'User views clients list' do
    visit admin_clients_path

    expect(page).to have_content('Clientes')
    expect(page).to have_content('João Silva')
    expect(page).to have_content(client.cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4'))
    expect(page).to have_content(client.phone)
    expect(page).to have_content("#{client.city}/#{client.state}")
  end

  scenario 'User creates a new client' do
    visit admin_clients_path
    click_link 'Novo Cliente'

    expect(page).to have_content('Novo Cliente')

    fill_in 'Nome', with: 'Maria Santos'
    fill_in 'CPF', with: '11144477735'  # CPF válido
    fill_in 'Telefone', with: '(11) 99999-9999'
    fill_in 'Endereço', with: 'Rua das Flores, 123'
    fill_in 'Cidade', with: 'São Paulo'
    select 'SP', from: 'Estado'
    fill_in 'CEP', with: '01234-567'

    click_button 'Salvar Cliente'

    expect(page).to have_content('Cliente foi criado com sucesso.')
    expect(page).to have_content('Maria Santos')
  end

  scenario 'User views client details' do
    visit admin_clients_path

    find("a[href='/admin/clients/#{client.id}']").click

    expect(page).to have_content(client.name)
    expect(page).to have_content('Dados Pessoais')
    expect(page).to have_content('Endereço')
    expect(page).to have_content(client.address)
    expect(page).to have_content(client.city)
    expect(page).to have_content(client.state)
  end

  scenario 'User edits a client' do
    visit admin_client_path(client)
    click_link 'Editar'

    expect(page).to have_content('Editar Cliente')

    fill_in 'Nome', with: 'João Silva Editado'
    fill_in 'Cidade', with: 'Rio de Janeiro'
    select 'RJ', from: 'Estado'

    click_button 'Atualizar Cliente'

    expect(page).to have_content('Cliente foi atualizado com sucesso.')
    expect(page).to have_content('João Silva Editado')
  end

  scenario 'User searches for clients' do
    create(:client, user: user, name: 'Maria Santos')

    visit admin_clients_path

    fill_in 'search', with: 'João'
    select 'Nome', from: 'search_type'
    click_button 'Buscar'

    expect(page).to have_content('João Silva')
    expect(page).to_not have_content('Maria Santos')
  end

  scenario 'User sorts clients' do
    create(:client, user: user, name: 'Ana Costa')
    create(:client, user: user, name: 'Zeca Lima')

    visit admin_clients_path

    select 'Nome (Z-A)', from: 'sort'
    click_button 'Buscar'

    # Verifica se a ordem está correta (Z-A)
    client_names = page.all('td .font-bold').map(&:text)
    expect(client_names.first).to eq('Zeca Lima')
    expect(client_names.last).to eq('Ana Costa')
  end

  scenario 'User deletes a client', js: true do
    visit admin_client_path(client)

    click_button 'Remover'

    # Aguarda o modal abrir e clica no botão de confirmação
    expect(page).to have_content('Confirmar Exclusão')
    click_button 'Sim, Remover'

    expect(page).to have_content('Cliente foi removido com sucesso.')
    expect(page).to have_current_path(admin_clients_path)
    expect(page).to_not have_content(client.name)
  end

  scenario 'User cannot access other user clients' do
    other_user = create(:user)
    other_client = create(:client, user: other_user)

    visit admin_client_path(other_client)

    expect(page).to have_current_path(admin_clients_path)
    expect(page).to have_content('Cliente não encontrado') # ou similar
  end

  scenario 'User sees validation errors' do
    visit admin_clients_path
    click_link 'Novo Cliente'

    # Tenta submeter formulário vazio
    click_button 'Salvar Cliente'

    expect(page).to have_content('não pode ficar em branco')
  end

  scenario 'User clears search filters' do
    visit admin_clients_path

    fill_in 'search', with: 'teste'
    click_button 'Buscar'

    click_link 'Limpar'

    expect(page).to have_content(client.name)
  end

  context 'when user is not signed in' do
    before { sign_out user }

    scenario 'redirects to login page' do
      visit admin_clients_path

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('Login')
    end
  end
end
