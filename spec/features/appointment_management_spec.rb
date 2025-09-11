require 'rails_helper'

RSpec.feature 'Appointment Management', type: :feature do
  let(:user) { create(:user) }
  let!(:past_appointment) { create(:appointment, :past, user: user, name: 'Reunião passada') }
  let!(:ongoing_appointment) { create(:appointment, :ongoing, user: user, name: 'Reunião atual') }
  let!(:upcoming_appointment) { create(:appointment, :upcoming, user: user, name: 'Próxima reunião') }

  before do
    sign_in_with_capybara(user)
  end

  scenario 'User views appointments list' do
    visit admin_appointments_path

    expect(page).to have_content('Compromissos')
    expect(page).to have_content('Gerencie seus compromissos agendados')

    # Verifica se os appointments estão sendo exibidos
    expect(page).to have_content('Reunião passada')
    expect(page).to have_content('Reunião atual')
    expect(page).to have_content('Próxima reunião')

    # Verifica as estatísticas
    expect(page).to have_content('Total de Compromissos')
    expect(page).to have_content('Próximos')
    expect(page).to have_content('Em Andamento')
    expect(page).to have_content('Passados')

    # Verifica os badges de status
    expect(page).to have_css('.badge', text: 'Passado')
    expect(page).to have_css('.badge', text: 'Em andamento')
    expect(page).to have_css('.badge', text: 'Próximo')
  end

  scenario 'User creates a new appointment' do
    visit admin_appointments_path
    click_link 'Novo Compromisso'

    expect(page).to have_content('Novo Compromisso')
    expect(page).to have_content('Preencha os dados do compromisso')

    fill_in 'Nome do Compromisso', with: 'Reunião importante'

    # Data e hora futuras
    start_time = 1.week.from_now.change(hour: 14, min: 0)
    end_time = start_time + 2.hours

    fill_in 'Data e Hora de Início', with: start_time.strftime('%Y-%m-%dT%H:%M')
    fill_in 'Data e Hora de Término', with: end_time.strftime('%Y-%m-%dT%H:%M')

    click_button 'Salvar Compromisso'

    expect(page).to have_content('Compromisso foi criado com sucesso.')
    expect(page).to have_content('Reunião importante')
  end

  scenario 'User tries to create appointment with invalid data' do
    visit admin_appointments_path
    click_link 'Novo Compromisso'

    # Submete formulário vazio
    click_button 'Salvar Compromisso'

    expect(page).to have_content('Erro ao salvar compromisso')
    expect(page).to have_content('Nome não pode ficar em branco')
    expect(page).to have_content('Data e hora de início não pode ficar em branco')
    expect(page).to have_content('Data e hora de término não pode ficar em branco')
  end

  scenario 'User tries to create appointment with time conflict' do
    visit admin_appointments_path
    click_link 'Novo Compromisso'

    fill_in 'Nome do Compromisso', with: 'Compromisso conflitante'

    # Usar horário que conflita com appointment existente
    start_time = upcoming_appointment.start_time + 30.minutes
    end_time = upcoming_appointment.end_time + 30.minutes

    fill_in 'Data e Hora de Início', with: start_time.strftime('%Y-%m-%dT%H:%M')
    fill_in 'Data e Hora de Término', with: end_time.strftime('%Y-%m-%dT%H:%M')

    click_button 'Salvar Compromisso'

    expect(page).to have_content('Conflito de horário detectado')
    expect(page).to have_content('Conflito de horário com o compromisso')
  end

  scenario 'User views appointment details' do
    visit admin_appointments_path

    # Clica no botão de visualizar do appointment
    within("tr", text: upcoming_appointment.name) do
      first('a[href*="/admin/appointments/"]').click
    end

    expect(page).to have_content(upcoming_appointment.name)
    expect(page).to have_content('Detalhes do Compromisso')
    expect(page).to have_content('Período do Compromisso')
    expect(page).to have_content('Status')
    expect(page).to have_content('Ações Rápidas')

    # Verifica informações do appointment
    expect(page).to have_content(upcoming_appointment.duration.to_s)
    expect(page).to have_content('horas')
  end

  scenario 'User edits an appointment' do
    visit admin_appointments_path

    # Clica no botão de editar
    within("tr", text: upcoming_appointment.name) do
      click_link(href: edit_admin_appointment_path(upcoming_appointment))
    end

    expect(page).to have_content('Editar Compromisso')
    expect(page).to have_content("Atualize os dados do compromisso \"#{upcoming_appointment.name}\"")

    fill_in 'Nome do Compromisso', with: 'Reunião atualizada'

    click_button 'Atualizar Compromisso'

    expect(page).to have_content('Compromisso foi atualizado com sucesso.')
    expect(page).to have_content('Reunião atualizada')
  end

  scenario 'User deletes an appointment' do
    visit admin_appointments_path

    expect(page).to have_content(upcoming_appointment.name)

    # Clica no botão de deletar (último botão na linha)
    within("tr", text: upcoming_appointment.name) do
      all('button').last.click
    end

    # Confirma a exclusão no modal
    within('#delete_confirmation_modal') do
      expect(page).to have_content('Confirmar Exclusão')
      click_button 'Sim, Remover'
    end

    expect(page).to have_content('Compromisso foi removido com sucesso.')
    expect(page).not_to have_content(upcoming_appointment.name)
  end

  scenario 'User searches for appointments' do
    visit admin_appointments_path

    fill_in 'search', with: 'passada'
    click_button 'Buscar'

    expect(page).to have_content('Reunião passada')
    expect(page).not_to have_content('Reunião atual')
    expect(page).not_to have_content('Próxima reunião')
  end

  scenario 'User filters appointments by status' do
    visit admin_appointments_path

    # Filtra por appointments passados
    select 'Passados', from: 'status'
    click_button 'Buscar'

    expect(page).to have_content('Reunião passada')
    expect(page).not_to have_content('Reunião atual')
    expect(page).not_to have_content('Próxima reunião')

    # Filtra por appointments futuros
    select 'Próximos', from: 'status'
    click_button 'Buscar'

    expect(page).to have_content('Próxima reunião')
    expect(page).not_to have_content('Reunião passada')
    expect(page).not_to have_content('Reunião atual')

    # Filtra por appointments em andamento
    select 'Em andamento', from: 'status'
    click_button 'Buscar'

    expect(page).to have_content('Reunião atual')
    expect(page).not_to have_content('Reunião passada')
    expect(page).not_to have_content('Próxima reunião')
  end

  scenario 'User clears search filters' do
    visit admin_appointments_path

    # Faz uma busca
    fill_in 'search', with: 'passada'
    select 'Passados', from: 'status'
    click_button 'Buscar'

    expect(page).to have_content('Reunião passada')
    expect(page).not_to have_content('Próxima reunião')

    # Limpa os filtros
    click_link 'Limpar'

    expect(page).to have_content('Reunião passada')
    expect(page).to have_content('Reunião atual')
    expect(page).to have_content('Próxima reunião')
  end

  scenario 'User sees empty state when no appointments exist' do
    # Remove todos os appointments
    user.appointments.destroy_all

    visit admin_appointments_path

    expect(page).to have_content('Nenhum compromisso encontrado')
    expect(page).to have_content('Comece adicionando seu primeiro compromisso')
    expect(page).to have_link('Adicionar Compromisso')
  end

  scenario 'User sees empty state for search with no results' do
    visit admin_appointments_path

    fill_in 'search', with: 'inexistente'
    click_button 'Buscar'

    expect(page).to have_content('Nenhum compromisso encontrado')
    expect(page).to have_content('Nenhum compromisso encontrado para "inexistente"')
  end

  scenario 'User navigates between appointment pages' do
    visit admin_appointments_path

    # Acessa detalhes
    within("tr", text: upcoming_appointment.name) do
      first('a[href*="/admin/appointments/"]').click
    end

    expect(page).to have_content(upcoming_appointment.name)

    # Navega para edição
    click_link 'Editar Compromisso'
    expect(page).to have_content('Editar Compromisso')

    # Volta para detalhes
    click_link(href: admin_appointment_path(upcoming_appointment))
    expect(page).to have_content('Detalhes do Compromisso')

    # Vai para novo compromisso
    click_link 'Novo Compromisso'
    expect(page).to have_content('Novo Compromisso')

    # Volta para lista
    visit admin_appointments_path
    expect(page).to have_content('Compromissos')
    expect(page).to have_content('Gerencie seus compromissos agendados')
  end
end
